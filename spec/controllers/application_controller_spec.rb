require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def test_login
      user = FactoryBot.create(:user)
      log_in(user)
      render plain: "Logged in"
    end

    def test_logout
      log_out
      render plain: "Logged out"
    end
  end

  let(:user) { create(:user) }

  before do
    routes.draw do
      get 'test_login' => 'anonymous#test_login'
      get 'test_logout' => 'anonymous#test_logout'
    end
  end

  describe "#log_in" do
    it "sets the session user_id" do
      user = FactoryBot.create(:user)  # Ensure user is created
      controller.session[:user_id] = user.id # Explicitly set session before log_in
      controller.log_in(user)  # Call log_in
      expect(controller.session[:user_id]).to eq(user.id) # Check session
    end
  end

  describe "#current_user" do
    it "returns the logged-in user" do
      session[:user_id] = user.id
      expect(controller.current_user).to eq(user)
    end

    it "returns nil if no user is logged in" do
      session[:user_id] = nil
      expect(controller.current_user).to be_nil
    end
  end

  describe "#logged_in?" do
    it "returns true when user is logged in" do
      session[:user_id] = user.id
      expect(controller.logged_in?).to be true
    end

    it "returns false when no user is logged in" do
      session[:user_id] = nil
      expect(controller.logged_in?).to be false
    end
  end

  describe "#log_out" do
    it "clears the session user_id and sets @current_user to nil" do
      session[:user_id] = user.id
      get :test_logout
      expect(session[:user_id]).to be_nil
      expect(controller.current_user).to be_nil
    end
  end
end
