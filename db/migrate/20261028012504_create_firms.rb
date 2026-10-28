class CreateFirms < ActiveRecord::Migration[8.1]
  def change
    create_table :firms do |t|
      t.string :name, null: false
      # Rails time zone name, e.g. "Pacific Time (US & Canada)". Decides what "today" and "overdue" mean.
      t.string :time_zone, null: false, default: "Pacific Time (US & Canada)"

      t.timestamps
    end
  end
end
