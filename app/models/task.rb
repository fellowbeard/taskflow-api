class Task < ApplicationRecord
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  has_many :task_events, dependent: :destroy

  scope :by_status, ->(status) { where(status: status) }

  scope :sorted_by_priority, lambda {
    reorder(
      Arel.sql(
        "CASE priority
          WHEN 'urgent' THEN 1
          WHEN 'high' THEN 2
          WHEN 'medium' THEN 3
          WHEN 'low' THEN 4
        END"
      )
    )
  }

  STATUSES = %w[queued assigned in_progress blocked completed cancelled].freeze
  PRIORITIES = %w[low medium high urgent].freeze

  VALID_TRANSITIONS = {
    "queued" => %w[assigned cancelled],
    "assigned" => %w[in_progress cancelled],
    "in_progress" => %w[blocked completed cancelled],
    "blocked" => %w[in_progress cancelled],
    "completed" => [],
    "cancelled" => []
  }.freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  before_validation :set_defaults, on: :create

  def transition_to!(new_status)
    new_status = new_status.to_s

    unless VALID_TRANSITIONS.fetch(status, []).include?(new_status)
      raise ArgumentError, "Cannot transition from #{status} to #{new_status}"
    end

    previous_status = status

    transaction do
      update!(status: new_status)

      task_events.create!(
        event_type: "status_changed",
        from_value: previous_status,
        to_value: new_status,
        metadata: {}
      )
    end
  end

  def assign_to!(user)
    previous_assignee = assigned_to&.name

    transaction do
      update!(
        assigned_to: user,
        status: status == "queued" ? "assigned" : status
      )

      task_events.create!(
        event_type: "assigned",
        from_value: previous_assignee,
        to_value: user.name,
        metadata: { user_id: user.id }
      )
    end
  end

  private

  def set_defaults
    self.status ||= "queued"
    self.priority ||= "medium"
  end
end