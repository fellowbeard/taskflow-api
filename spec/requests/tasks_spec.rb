require "rails_helper"

RSpec.describe "Tasks API", type: :request do
  describe "GET /tasks" do
  it "returns all tasks" do
    Task.create!(title: "Task 1", priority: "low")
    Task.create!(title: "Task 2", priority: "high")

    get "/tasks"

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json.length).to eq(2)
  end

  it "filters tasks by status" do
    Task.create!(title: "Task 1", priority: "low")
    task = Task.create!(title: "Task 2", priority: "high")
    task.transition_to!("assigned")

    get "/tasks", params: { status: "assigned" }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json.length).to eq(1)
    expect(json.first["status"]).to eq("assigned")
  end

  it "sorts tasks by priority" do
    Task.create!(title: "Low task", priority: "low")
    Task.create!(title: "Urgent task", priority: "urgent")

    get "/tasks", params: { sort: "priority" }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json.first["priority"]).to eq("urgent")
    expect(json.last["priority"]).to eq("low")
  end

  it "paginates tasks" do
    Task.create!(title: "Task 1")
    Task.create!(title: "Task 2")
    Task.create!(title: "Task 3")

    get "/tasks", params: { page: 2, per_page: 1 }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)

    expect(json.length).to eq(1)
    expect(json.first["title"]).to eq("Task 2")
  end
end

  describe "POST /tasks" do
    it "creates a task" do
      post "/tasks", params: {
        task: { title: "Build workflow engine" }
      }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Build workflow engine")
      expect(json["status"]).to eq("queued")
    end
  end

  describe "PATCH /tasks/:id/assign" do
    it "assigns a task to a user" do
      user = User.create!(name: "Michael", email: "michael@example.com")
      task = Task.create!(title: "Test task")

      patch "/tasks/#{task.id}/assign", params: {
        user_id: user.id
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["assigned_to_id"]).to eq(user.id)
      expect(json["status"]).to eq("assigned")
      expect(json["task_events"].last["event_type"]).to eq("assigned")
    end
  end

  describe "PATCH /tasks/:id/transition" do
    it "transitions a task and logs event" do
      task = Task.create!(title: "Test task")

      patch "/tasks/#{task.id}/transition", params: {
        status: "assigned"
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("assigned")
      expect(json["task_events"].last["event_type"]).to eq("status_changed")
    end

    it "rejects invalid transitions" do
      task = Task.create!(title: "Test task")

      patch "/tasks/#{task.id}/transition", params: {
        status: "completed"
      }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["error"]).to include("Cannot transition")
    end
  end

  describe "GET /tasks/:id" do
    it "returns task with events" do
      task = Task.create!(title: "Test task")
      task.transition_to!("assigned")

      get "/tasks/#{task.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["id"]).to eq(task.id)
      expect(json["task_events"].length).to be > 0
    end
  end
end