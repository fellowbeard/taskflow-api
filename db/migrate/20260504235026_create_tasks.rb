class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :status
      t.string :priority
      t.integer :assigned_to_id
      t.date :due_date

      t.timestamps
    end
  end
end
