class TasksController < ApplicationController
  before_action :set_task, only: [:show, :assign, :transition]

  def index
    tasks = Task.order(:id)

    tasks = tasks.by_status(params[:status]) if params[:status].present?
    tasks = tasks.sorted_by_priority if params[:sort] == "priority"

    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10

    tasks = tasks.offset((page - 1) * per_page).limit(per_page)

    render json: tasks.map { |task| task_json(task) }
  end

  def show
    render json: task_json(@task)
  end

  def create
    task = Task.create!(task_params)
    render json: task_json(task), status: :created
  end

  def assign
    user = User.find(params[:user_id])
    @task.assign_to!(user)

    render json: task_json(@task)
  end

  def transition
    @task.transition_to!(params[:status])

    render json: task_json(@task)
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def task_json(task)
    {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigned_to_id: task.assigned_to_id,
      assigned_to_name: task.assigned_to&.name,
      task_events: task.task_events.map do |event|
        {
          id: event.id,
          event_type: event.event_type,
          from_value: event.from_value,
          to_value: event.to_value
        }
      end
    }
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority)
  end
end