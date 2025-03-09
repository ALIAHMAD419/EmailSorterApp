class EmailsController < ApplicationController
  before_action :require_login

  def index
    if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      if category
        @emails = Email.where(category_id: category.id)
        @category_name = category.name
      else
        flash[:alert] = "Category not found"
        redirect_to categories_path and return
      end
    else
      flash[:notice] = "No emails found"
    end
  end

  def show
    @category = Category.find(params[:category_id])
    @email = @category.emails.find(params[:id])
  end

  def destroy
    @category = Category.find(params[:category_id])
    @email = @category.emails.find(params[:id])
    @email.destroy
    flash[:success] = "Email deleted successfully."
    redirect_to category_emails_path
  end



  def bulk_action
    action = params[:action_type]
    email_ids = params[:email_ids]

    if email_ids.blank?
      flash[:error] = "No emails selected."
    else
      case action
      when "delete"
        Email.where(id: email_ids).destroy_all
        # Email.where(id: email_ids)
        flash[:success] = "Selected emails have been deleted."
      when "unsubscribe"
        puts "Unsubscribing from emails with IDs: #{email_ids.join(', ')}"
        flash[:info] = "Unsubscribe action is in progresss."
      else
        flash[:error] = "Invalid action selected."
      end
    end

    category = Email.find_by(id: email_ids&.first)&.category
    redirect_to category ? category_emails_path(category) : categories_path
  end

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this page!"
      redirect_to root_path # Redirect to home page or login page
    end
  end
end
