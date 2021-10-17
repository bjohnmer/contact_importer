FactoryBot.define do
  factory :import_summary do
    imported_file
    stats { "" }
    messages { "" }
  end
end
