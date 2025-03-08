class User < ApplicationRecord
  has_many :categories
  has_many :emails

  def self.from_omniauth(response)
    user = User.find_or_create_by(uid: response[:uid], provider: response[:provider]) do |u|
      u.name = response[:info][:name]
      u.email = response[:info][:email]
      u.google_token = response[:credentials][:token]
      u.google_refresh_token = response[:credentials][:refresh_token] if response[:credentials][:refresh_token].present?
      u.google_token_expires_at = Time.at(response[:credentials][:expires_at])
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
    return nil unless google_token
  
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
        puts "🔄 Refreshing Google token..."
        return refresh_google_token(client)
      else
        puts "⚠️ No refresh token available. User may need to reauthenticate."
        return nil  # Return nil to force re-authentication in the app
      end
    end
  
    client
  end

  private
  
  def refresh_google_token(client)
    begin
      response = client.refresh!
      update!(
        google_token: response.access_token,
        google_token_expires_at: Time.now + response.expires_in.to_i.seconds
      )

      puts "✅ Google token refreshed successfully!"
      response.access_token
    rescue Signet::AuthorizationError => e
      puts "⚠️ Token refresh failed: #{e.message}. Logging out user."
      
      # Reset credentials so they must reauthenticate
      update!(
        google_token: nil, 
        google_refresh_token: nil, 
        google_token_expires_at: nil
      )

      nil
    end
  end
end
