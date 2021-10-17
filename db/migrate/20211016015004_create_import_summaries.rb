class CreateImportSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :import_summaries do |t|
      t.belongs_to :imported_file, foreign_key: true
      t.string :stats
      t.string :messages
      
      t.timestamps null: false
    end
  end
end
