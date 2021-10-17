FactoryBot.define do
  factory :contact do
    name { Faker::Name.first_name }
    dob { Faker::Date.birthday(min_age: 18, max_age: 65) }
    phone { "(+#{rand(1..999)})#{rand(100..999)} #{rand(100..999)} #{rand(10..99)} #{rand(10..99)}"}
    address { Faker::Address.full_address }
    credit_card { Faker::Finance.credit_card(:mastercard).delete('-') }
    email { Faker::Internet.email }
    user

    trait :with_wrong_phone do
      phone { '999999--oo'}
    end

    trait :with_missing_data do
      dob { nil }
      name { nil }
      email { nil }
    end
  end
end
