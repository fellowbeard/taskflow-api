require "rails_helper"

RSpec.describe Task, type: :model do
  describe "defaults" do
    it "sets default status and priority on create" do
      task = Task.create!(title: "Review workflow")

      expect(task.status).to eq("queued")
      expect(task.priority).to eq("medium")
    end
  end

  describe "#transition_to!" do
    it "allows valid transitions" do
      task = Task.create!(title: "Review workflow")

      task.transition_to!("assigned")

      expect(task.status).to eq("assigned")
    end

    it "blocks invalid transitions" do
      task = Task.create!(title: "Review workflow")

      expect {
        task.transition_to!("completed")
      }.to raise_error(ArgumentError, "Cannot transition from queued to completed")

      expect(task.reload.status).to eq("queued")
    end

    it "creates an audit event when status changes" do
      task = Task.create!(title: "Review workflow")

      task.transition_to!("assigned")

      event = task.task_events.last

      expect(event.event_type).to eq("status_changed")
      expect(event.from_value).to eq("queued")
      expect(event.to_value).to eq("assigned")
      expect(event.metadata).to eq({})
    end
  end

  describe "#assign_to!" do
    it "assigns the task to a user" do
      user = User.create!(name: "Michael", email: "michael@example.com")
      task = Task.create!(title: "Review workflow")

      task.assign_to!(user)

      expect(task.assigned_to).to eq(user)
    end

    it "moves queued tasks to assigned" do
      user = User.create!(name: "Michael", email: "michael@example.com")
      task = Task.create!(title: "Review workflow")

      task.assign_to!(user)

      expect(task.status).to eq("assigned")
    end

    it "does not override a non-queued status" do
      user = User.create!(name: "Michael", email: "michael@example.com")
      task = Task.create!(title: "Review workflow", status: "in_progress")

      task.assign_to!(user)

      expect(task.status).to eq("in_progress")
    end

    it "creates an audit event when assigned" do
      user = User.create!(name: "Michael", email: "michael@example.com")
      task = Task.create!(title: "Review workflow")

      task.assign_to!(user)

      event = task.task_events.last

      expect(event.event_type).to eq("assigned")
      expect(event.from_value).to be_nil
      expect(event.to_value).to eq("Michael")
      expect(event.metadata).to eq({ "user_id" => user.id })
    end
  end
end