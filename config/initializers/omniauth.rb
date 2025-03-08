require "omniauth-google-oauth2"

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.allowed_request_methods = [ :post, :get ]
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
  scope: "email, profile, https://www.googleapis.com/auth/gmail.modify",
  access_type: "offline", prompt: "consent"
end
