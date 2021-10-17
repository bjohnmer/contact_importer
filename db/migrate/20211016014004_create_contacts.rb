class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.date :dob, null: false
      t.string :phone, null: false
      t.text :address, null: false
      t.string :credit_card, null: false
      t.string :franchise
      t.string :email, null: false
      t.belongs_to :user, foreign_key: true

      t.timestamps null: false
    end

    add_index :contacts, [:user_id, :email], unique: true
  end
end
