FactoryBot.define do
  factory :imported_file do
    file_name { 'file' }
    status { :on_hold }
    file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/contacts.csv", 'text/csv') }
    user
  end
end
