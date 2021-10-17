class ImportedFilesController < ApplicationController
  before_action :import_params, only: [:import]

  def index
    @imported_files = current_user.imported_files.order(created_at: :desc).page(params[:page]).per(10)
  end

  def upload
    @columns = valid_columns
  end

  def import
    if params['csv_file'].present?
      result = CsvClientsImporter.csv_import!(current_user, params['csv_file'], import_params)

      notice = result[:errors].present? ? result[:errors] : 'CSV impoted successfully'
      imported_file = current_user.imported_files.create(file_name: params['csv_file'].original_filename, status: result[:status], file: params['csv_file'])
      imported_file.import_summaries.create(stats: result[:stats], messages: result[:errors] )

      path = imported_files_index_path
    else
      path = imported_files_upload_path
      notice = 'Error, No file selected'
    end

    redirect_to path, flash: { notice: notice }
  end

  def show
    @summary = ImportedFile.find(params[:id]).import_summaries.first
  end

  private

  def import_params
    params.permit(
      permitted_params
    )
  end

  def permitted_params
    form_fields = []
    valid_columns.each_with_index do |col, index|
      form_fields.push("col_#{index}")
      form_fields.push("input_#{index}")
    end

    form_fields
  end

  def valid_columns
    Contact.column_names.reject { |column| %w[id franchise created_at updated_at user_id].include?(column) }
  end
end
