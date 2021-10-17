FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'test1234' }

    trait :with_imported_files do
      after(:build) do |n|
        n.imported_files << create(:imported_file, :with_summaries)
        n.imported_files << create(:imported_file, :with_summaries)
      end
    end

    trait :with_contacts do
      after(:build) do |n|
        n.contacts << create(:contact)
        n.contacts << create(:contact)
      end
    end
  end
end
