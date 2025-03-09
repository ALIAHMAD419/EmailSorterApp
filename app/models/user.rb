require "googleauth"

class User < ApplicationRecord
  has_many :categories
  has_many :emails, dependent: :destroy

  has_many :children, class_name: "User", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "User", optional: true

  def owner?
    parent_id.nil? # Owner has no parent
  end

  def self.from_omniauth(response, parent_user = nil)
    user = User.find_or_initialize_by(uid: response[:uid], provider: response[:provider]) do |u|
      u.name = response[:info][:name]
      u.email = response[:info][:email]
      u.google_token = response[:credentials][:token]
      u.google_refresh_token = response[:credentials][:refresh_token] if response[:credentials][:refresh_token].present?
      u.google_token_expires_at = Time.at(response[:credentials][:expires_at])
    end

    if parent_user && user.new_record?
      user.parent_id = parent_user.id
    end

    user.save!

    if user.persisted? && user.categories.empty? && user.parent_id.nil?
      user.categories.create([
        { name: "Work", description: "Emails related to work" },
        { name: "Promotions", description: "Promotional emails" },
        { name: "Personal", description: "Personal emails" },
        { name: "Default", description: "Emails that don't fit other categories." }
      ])
    end

    user
  end

  # Helper method to update Google tokens
  def update_google_tokens(credentials)
    self.google_token = credentials.token
    self.google_refresh_token = credentials.refresh_token if credentials.refresh_token.present?
    self.google_token_expires_at = Time.at(credentials.expires_at)
    save
  end

  def google_credentials
    return { success: false, message: "⚠️ No Google token available." } unless google_token

    client = Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      token_credential_uri: "https://oauth2.googleapis.com/token",
      access_token: google_token,
      refresh_token: google_refresh_token,
      expires_at: google_token_expires_at.to_i
    )

    if google_token_expires_at.nil? || client.expired? || google_token_expires_at < 5.minutes.from_now
      if google_refresh_token.present?
        refresh_result = refresh_google_token(client)
        return refresh_result if refresh_result[:success] == false

        { success: true, message: "✅ Google token refreshed successfully!", token: refresh_result[:token] }
      else
        { success: false, message: "⚠️ No refresh token available. User may need to reauthenticate." }
      end
    else
    { success: true, message: "✅ Token is still valid. No refresh needed yet.", token: google_token }
    end
  end

  private

  def refresh_google_token(client)
    begin
      response = client.refresh!
      update!(
        google_token: response["access_token"],
        google_token_expires_at: Time.now + response["expires_in"].to_i.seconds
      )

      { success: true, message: "✅ Google token refreshed successfully!", token: response["access_token"] }
    rescue Signet::AuthorizationError => e
      update!(google_token: nil, google_refresh_token: nil, google_token_expires_at: nil)

      { success: false, message: "⚠️ Token refresh failed: #{e.message}. User must reauthenticate." }
    end
  end
end
