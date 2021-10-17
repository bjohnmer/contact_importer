FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'test1234' }

    trait :with_imported_files do
      after(:build) do |n|
        n.imported_file << FactoryBot.create(:imported_file)
        n.imported_file << FactoryBot.create(:imported_file)
      end
    end
  end
end
