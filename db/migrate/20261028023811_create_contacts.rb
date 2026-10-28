class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :firm, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.string :phone

      t.timestamps
    end
    add_index :contacts, [ :firm_id, :name ]
  end
end
