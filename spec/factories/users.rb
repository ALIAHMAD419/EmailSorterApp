FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    google_token { SecureRandom.hex(20) }
    google_refresh_token { SecureRandom.hex(20) }
    google_token_expires_at { Time.current + 1.hour }
    uid { SecureRandom.uuid }
    provider { "google_oauth2" }
  end
end
