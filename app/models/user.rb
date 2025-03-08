class User < ApplicationRecord
  has_many :categories

  def self.from_omniauth(response)
    User.find_or_create_by(uid: response[:uid], provider: response[:provider]) do |u|
      u.name = response[:info][:name]
      u.email = response[:info][:email]
    end
  end

  # Helper method to update Google tokens
  def update_google_tokens(credentials)
    self.google_token = credentials.token
    self.google_refresh_token = credentials.refresh_token if credentials.refresh_token.present?
    save
  end
end
