class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :matter, foreign_key: true
      t.string :title, null: false
      t.string :location
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end
  end
end
