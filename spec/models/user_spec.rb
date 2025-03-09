require "rails_helper"
require "ostruct"  # Add this to use OpenStruct

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:categories) }
    it { should have_many(:emails) }
  end

  describe ".from_omniauth" do
    let(:auth_response) do
      {
        uid: "12345",
        provider: "google_oauth2",
        info: { name: "Test User", email: "test@example.com" },
        credentials: {
          token: "test_token",
          refresh_token: "test_refresh_token",
          expires_at: Time.now.to_i + 3600
        }
      }.deep_symbolize_keys
    end

    context "when user does not exist" do
      it "creates a new user with correct attributes" do
        user = User.from_omniauth(auth_response)

        expect(user).to be_persisted
        expect(user.uid).to eq(auth_response[:uid])
        expect(user.provider).to eq(auth_response[:provider])
        expect(user.name).to eq(auth_response[:info][:name])
        expect(user.email).to eq(auth_response[:info][:email])
        expect(user.google_token).to eq(auth_response[:credentials][:token])
        expect(user.google_refresh_token).to eq(auth_response[:credentials][:refresh_token])
        expect(user.google_token_expires_at).to be_within(1.second).of(Time.at(auth_response[:credentials][:expires_at]))
      end

      it "creates default categories for the user" do
        user = User.from_omniauth(auth_response)
        expect(user.categories.count).to eq(4)
        expect(user.categories.pluck(:name)).to match_array([ "Work", "Promotions", "Personal", "Default" ])
      end
    end

    context "when user already exists" do
      let!(:existing_user) { create(:user, uid: auth_response[:uid], provider: auth_response[:provider]) }

      it "does not create a new user" do
        expect { User.from_omniauth(auth_response) }.not_to change(User, :count)
      end

      it "returns the existing user" do
        user = User.from_omniauth(auth_response)
        expect(user).to eq(existing_user)
      end
    end
  end

  describe "#update_google_tokens" do
    let(:user) { create(:user) }
    let(:credentials) { OpenStruct.new(token: "new_token", refresh_token: "new_refresh", expires_at: Time.now.to_i + 3600) }

    it "updates the user's Google tokens" do
      user.update_google_tokens(credentials)

      expect(user.google_token).to eq(credentials.token)
      expect(user.google_refresh_token).to eq(credentials.refresh_token)
      expect(user.google_token_expires_at).to be_within(1.second).of(Time.at(credentials.expires_at))
    end
  end
end
