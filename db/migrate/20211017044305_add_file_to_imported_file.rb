class AddFileToImportedFile < ActiveRecord::Migration[6.1]
  def change
    add_column :imported_files, :file, :string
  end
end
