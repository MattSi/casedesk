class CreateMatters < ActiveRecord::Migration[8.1]
  def change
    create_table :matters do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :contacts }
      t.string :number, null: false
      t.string :title, null: false
      t.string :practice_area
      t.string :status, null: false, default: "open"
      t.date :opened_on

      t.timestamps
    end
    add_index :matters, [ :firm_id, :number ], unique: true
  end
end
