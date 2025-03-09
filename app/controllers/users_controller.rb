class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [ :destroy, :user_refresh_token ]

  def destroy
    if @user.nil?
      flash[:error] = "User not found."
      redirect_to categories_path and return
    end

    if @user.parent_id
      @user.destroy
      flash[:success] = "User deleted successfully."
    else
      flash[:error] = "User is a Parent and cannot be deleted."
    end

    redirect_to categories_path
  end

  def user_refresh_token
    unless @user
      flash[:error] = "User not found."
      return redirect_back fallback_location: categories_path
    end

    if @user.google_token.present?
      result = @user.google_credentials

      if result[:success]
        flash[:success] = result[:message]
      else
        flash[:error] = result[:message]
      end
    else
      flash[:error] = "⚠️ No refresh token available. User needs to reauthenticate."
    end

    redirect_back fallback_location: categories_path
  end


  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "User not found."
    redirect_back fallback_location: categories_path
  end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this page!"
      redirect_to root_path
    end
  end
end
