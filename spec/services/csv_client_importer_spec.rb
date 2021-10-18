require 'rails_helper'
require './app/services/csv_clients_importer'

RSpec.describe CsvClientsImporter do

  def columns
    Contact.column_names.reject { |column| %w[id franchise created_at updated_at user_id].include?(column) }
  end

  def valid_columns
    file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts.csv','text/csv')
    data = file.read

   csv_options = {
      headers: true,
      encoding: 'UTF-8',
      col_sep: ',',
      skip_blanks: true,
      skip_lines: /^(?:,\s*)+$/,
      header_converters: ->(f) { f&.strip },
      converters: ->(f) { f&.strip }
    }

    file_data = CSV.parse(data, csv_options)
    file_keys = file_data[0].to_hash.keys

    column_data = {}

    columns.each_with_index do |col, index|
      column_data["col_#{index}"] = col
      column_data["input_#{index}"]= file_keys[index]
    end

    column_data
  end

 let(:user) { create(:user) }

  describe '#import_contacts' do
    it 'imports contacts when some errors occur' do
      file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, file, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('invalid')
      expect(result[:errors]).to include('can\'t be blank')
    end

    it 'imports contacts from XLSX file when some errors occur' do
      pdf = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_xlsx.xlsx','application/vnd.ms-excel')

      result = CsvClientsImporter::csv_import!(user, pdf, valid_columns)
 
      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('invalid')
      expect(result[:errors]).to include('can\'t be blank')
    end

    it 'imports contacts when CSV is all valid' do
      valid_file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_all_valid_data.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, valid_file, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to eq("")
    end

    it 'does not import when CSV file is empty but headers present' do
      empty_file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_empty.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, empty_file, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('The CSV file is empty')
    end

    it 'does not import when CSV file is empty when no headers present' do
      no_records_file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_no_records.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, no_records_file, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('The CSV file is empty')
    end

    it 'does not import when columns not match' do
      no_match = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_no_match_columns.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, no_match, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('Columns written don\'t match with the file columns')
    end

    it 'does not import when columns missing' do
      missing_column_file = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_missing_columns.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, missing_column_file, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('Columns written don\'t match with the file columns')
    end

    it 'imports data even when duplicated rows' do
      duplicated = fixture_file_upload(Rails.root + 'spec/fixtures/contacts_duplicated_data.csv','text/csv')

      result = CsvClientsImporter::csv_import!(user, duplicated, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to eq("")
    end

    it 'does not import when wrong file type' do
      pdf = fixture_file_upload(Rails.root + 'spec/fixtures/contact_wrong_file_type.pdf','text/pdf')

      result = CsvClientsImporter::csv_import!(user, pdf, valid_columns)

      expect(result.include?(:stats)).to be true
      expect(result.include?(:errors)).to be true
      expect(result[:errors]).to include('Invalid file type, It should be CSV (.csv) o Excel (.xlsx)')
    end
  end
end
