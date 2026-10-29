class AddTodayIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, [ :assignee_id, :status, :due_at ]
    add_index :calendar_events, [ :user_id, :starts_at ]

    # The new indexes start with these columns, so these are no longer needed
    remove_index :tasks, :assignee_id
    remove_index :calendar_events, :user_id
  end
end
