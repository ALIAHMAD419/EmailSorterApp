require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET #googleAuth" do
    let(:user) { create(:user) }
    let(:auth_data) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: user.uid,
        info: { email: user.email, name: user.name },
        credentials: { token: "test_token", refresh_token: "test_refresh", expires_at: Time.now.to_i + 3600 }
      )
    end

    before do
      request.env["omniauth.auth"] = auth_data
      allow(User).to receive(:from_omniauth).and_return(user)
      allow(user).to receive(:persisted?).and_return(true)
      allow(user).to receive(:update_google_tokens)
    end
  end

  describe "DELETE #destroy" do
    it "logs out the user and redirects to root path" do
      session[:user_id] = 1
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Logged out successfully.")
    end
  end

  describe "GET #failure" do
    it "redirects to root path with an authentication failure alert" do
      get :failure
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Authentication failed, please try again.")
    end
  end
end
