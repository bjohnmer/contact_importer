FactoryBot.define do
  factory :imported_file do
    file_name { 'file' }
    status { :on_hold }
    file { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/contacts.csv", 'text/csv') }
    user

    trait :with_summaries do
      after(:build) do |n|
        n.import_summaries << create(:import_summary)
        n.import_summaries << create(:import_summary)
      end
    end
  end
end
