class SessionsController < ApplicationController
  def googleAuth
    access_token = request.env["omniauth.auth"]
    user = User.from_omniauth(access_token)

    if user.persisted?
      log_in(user)
      user.update_google_tokens(access_token.credentials)
      redirect_to root_path, notice: "Successfully signed in with Google!"
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
