require 'rails_helper'

RSpec.describe CsvGeneratorJob, type: :job do
  let(:valid_params) {
    params = {}
    valid_columns.each_with_index do |p, index|
      if p == 'dob'
        params["col_#{index}"] = p
        params["input_#{index}"] = 'Date of Birth'

        next
      end
      params["col_#{index}"] = p
      params["input_#{index}"] = p.humanize.titleize
    end
    params.merge!(csv_file: Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/contacts.csv", 'text/csv'))
    params
  }

  def valid_columns
    Contact.column_names.reject { |column| %w[id franchise created_at updated_at user_id].include?(column) }
  end

  describe '#perform' do
    let(:success) {
      {
        stats: {
          total: 20,
          new: 7,
          edit: 13
        },
        status: :finished,
        errors: 'Row 7 invalid: Dob can’t be blank, Dob invalid, Row 9 invalid: Phone can’t be blank'
      }
    }

    let(:failed) {
      {
        stats: {
          total: 0,
          new: 0,
          edit: 0
        },
        status: :failed,
        errors: 'Columns written don’t match with the file columns'
      }
    }

    let(:user) { create(:user) }
    let(:imported_file) { create(:imported_file, user: user, file: valid_params[:csv_file]) }
    let(:the_file) { valid_params[:csv_file] }

    it 'exec the CsvClientsImporter.csv_import! and sets the imported_file.status as finished if success' do
      allow(URI).to receive(:parse).with(anything()).and_return(the_file)
      allow(CsvClientsImporter).to receive(:csv_import!).and_return(success)
      expect(CsvClientsImporter).to receive(:csv_import!).with(user, anything(), valid_params)

      expect(imported_file.status).to eq('on_hold')
      CsvGeneratorJob.perform_now(imported_file.id, valid_params)

      imported_file.reload
      expect(imported_file.status).to eq('finished')
    end

    it 'sets imported_file.status as failed if CsvClientsImporter failed' do
      allow(URI).to receive(:parse).with(anything()).and_return(the_file)
      allow(CsvClientsImporter).to receive(:csv_import!).and_return(failed)
      expect(CsvClientsImporter).to receive(:csv_import!).with(user, anything(), valid_params)

      expect(imported_file.status).to eq('on_hold')
      CsvGeneratorJob.perform_now(imported_file.id, valid_params)

      imported_file.reload
      expect(imported_file.status).to eq('failed')
    end
  end
end
