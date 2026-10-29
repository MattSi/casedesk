class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :matter, null: false, foreign_key: true
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.datetime :due_at
      t.string :status, null: false, default: "open"
      t.datetime :completed_at

      t.timestamps
    end
  end
end
