FactoryBot.define do
  factory :email do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    summary { Faker::Lorem.sentence }
    gmail_message_id { SecureRandom.hex(10) }
    association :category
    association :user
  end
end
