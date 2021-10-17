class ImportedFile < ApplicationRecord
  belongs_to :user
  has_many :import_summaries

  enum status: %i[on_hold processing failed finished]

  has_one_attached :file
end
