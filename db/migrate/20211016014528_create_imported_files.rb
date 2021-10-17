class CreateImportedFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :imported_files do |t|
      t.string :file_name
      t.integer :status
      t.belongs_to :user, foreign_key: true

      t.timestamps null: false
    end
  end
end
