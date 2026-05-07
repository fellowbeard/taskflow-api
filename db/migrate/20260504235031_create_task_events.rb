class CreateTaskEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :task_events do |t|
      t.references :task, null: false, foreign_key: true
      t.string :event_type
      t.string :from_value
      t.string :to_value
      t.jsonb :metadata

      t.timestamps
    end
  end
end
