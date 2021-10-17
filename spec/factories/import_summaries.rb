FactoryBot.define do
  factory :import_summary do
    imported_file { nil }
    row { "MyString" }
    error { "MyString" }
    imported { false }
  end
end
