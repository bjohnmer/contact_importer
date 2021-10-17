require 'open-uri'

class CsvGeneratorJob < ApplicationJob
  queue_as :default

  def perform(file_id, import_params)
    file = ImportedFile.find(file_id)
    file.status = :processing
    file.save

    user = file.user

    file_url = Rails.application.routes.url_helpers.rails_blob_url(file.file)
    the_file = URI.parse(file_url).open

    result = CsvClientsImporter.csv_import!(user, the_file, import_params)

    file.status = result[:status]
    file.save

    file.import_summaries.create(stats: result[:stats], messages: result[:errors] )
  end
end
