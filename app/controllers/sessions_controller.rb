class SessionsController < ApplicationController
  def googleAuth
    access_token = request.env["omniauth.auth"]
    current_user = User.find(session[:user_id]) if session[:user_id]
    user = User.from_omniauth(access_token, current_user)

    if user.persisted?
      log_in(user) if session[:user_id].nil? && user.parent_id.nil?

      user.update_google_tokens(access_token.credentials)
      redirect_to categories_path, notice: "Successfully signed in with Google!"
    else
      redirect_to login_path, alert: "Google authentication failed."
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "Logged out successfully."
  end

  def failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end
end
