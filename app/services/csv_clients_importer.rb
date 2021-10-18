require 'csv'
require 'roo'

class CsvClientsImporter
  CSV_FILE_TYPES = [
    '.csv',
    'application/csv',
    'application/x-csv',
    'application/vnd.ms-excel',
    'text/csv',
    'text/plain',
    'text/x-csv',
    'text/comma-separated-values',
    'text/x-comma-separated-values',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ]

  class << self
    def csv_import!(user, file, column_data)
      @errors = { errors: [] }
      @stats = init_stats

      file_type = file.content_type
      return { stats: @stats, status: :failed, errors: @errors[:errors].join(', ') } unless right_file_type?(file_type)

      @emails_in_csv = {}.with_indifferent_access

      @cleaned_fields = column_data_prepare(column_data)

      rows = parse_file!(file,file_type)

      @contacts_by_email = contacts_by_email(rows)

      has_errors = @errors[:errors].include?('Columns written don\'t match with the file columns')
      return { stats: @stats, status: :failed, errors: @errors[:errors].join(', ') } if has_errors
      return { stats: @stats, status: :failed, errors: 'The CSV file is empty' } unless rows.any?

      results(user, rows)
    end

    def results(user, rows)
      result = {}
      Contact.transaction do
        errors = []
        contacts = contact_rows(user, rows)

        contacts.each_with_index do |contact, index|
          next if contact.save

          row_number = index + 2
          errors << error_message(row_number, contact.errors.full_messages.join(', '))
        end

        status = errors.length == contacts.length ? :failed : :finished
        result = { stats: @stats, status: status, errors: errors.join(', ') }
      end

      result
    end

    def contact_rows(user, rows)
      new_contact = []
      rows.map do |row|
        if row.present?
          new_contact << build_contact(user, row)
        end
      end

      new_contact
    end

    def column_data_prepare(column_data)
      cleaned = {}.with_indifferent_access

      column_data.to_h.keys.each_with_index do |_col, index|
        break unless column_data["col_#{index}"]

        cleaned[column_data["col_#{index}"]] = column_data["input_#{index}"]
      end

      cleaned
    end

    def init_stats
      {
        total: 0,
        new: 0,
        edit: 0
      }
    end

    def parse_file!(file, file_type)
      file_data = parsed_file(file,file_type)
      return [] if file_data.blank?

      file_data.map.with_index do |row, index|
        row_number = index + 2
        row[@cleaned_fields['email']].downcase!

        next if duplicated?(row[@cleaned_fields['email']], row_number)

        @emails_in_csv.merge!("#{row[@cleaned_fields['email']]}": true)

        row.to_h
      end
    end

    def parsed_file(file, file_type)
      data = if [
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel'
      ].include?(file_type)
               xlsx = Roo::Spreadsheet.open(file)
               xlsx.to_csv
             else
               file.read
             end
      # data.gsub!(';', ',')

      file_data(data)
    end

    def csv_options
      {
        headers: true,
        encoding: 'UTF-8',
        col_sep: ',',
        skip_blanks: true,
        skip_lines: /^(?:,\s*)+$/,
        header_converters: ->(f) { f&.strip },
        converters: ->(f) { f&.strip }
      }
    end

    def file_data(data)
      data = CSV.parse(data, csv_options)

      if data.empty?
        @errors[:errors] << ['The CSV file is empty']
        return
      end

      file_headers = data.headers.compact.map(&:strip)
      return unless right_headers?(file_headers)

      data
    end

    def right_file_type?(file_type)
      unless CSV_FILE_TYPES.include?(file_type)
        @errors[:errors] << type_error_message
        return false
      end

      true
    end

    def type_error_message
      ['Invalid file type, It should be CSV (.csv) o Excel (.xlsx)']
    end

    def right_headers?(file_headers)
      return true if file_headers.empty?

      if (@cleaned_fields.values - file_headers).any?
        @errors[:errors] << 'Columns written don\'t match with the file columns'
        return false
      end

      true
    end

    def duplicated?(email, row_number)
      if @emails_in_csv[email].present?
        @errors[:errors] << error_message(row_number, "#{email} duplicated")
        return true
      end

      false
    end

    def contacts_by_email(rows)
      emails = rows.filter_map do |row|
        next unless row.present?

        row[@cleaned_fields['email']].downcase if row[@cleaned_fields['email']].present?
      end

      Contact.where(email: emails).index_by(&:email)
    end

    def error_message(row_number, message)
      "Row #{row_number} invalid: #{message}"
    end

    def build_contact(user, row)
      final_row = {
        user_id: user.id,
        email: row[@cleaned_fields['email']],
        dob: row[@cleaned_fields['dob']],
        phone: row[@cleaned_fields['phone']],
        name: row[@cleaned_fields['name']],
        credit_card: row[@cleaned_fields['credit_card']],
        address: row[@cleaned_fields['address']]
      }.with_indifferent_access

      contact_object(final_row)
    end

    def contact_object(row)
      if @contacts_by_email[row['email']]
        contact = @contacts_by_email[row['email']]
        contact.assign_attributes(row)
        add_to_stats(:edit)
      else
        contact = Contact.new(row)
        add_to_stats(:new)
      end

      contact.run_callbacks(:save) { false }
      contact
    end

    def add_to_stats(status)
      @stats[:total] += 1

      case status
      when :new
        @stats[:new] += 1
      when :edit
        @stats[:edit] += 1
      end
    end
  end
end
