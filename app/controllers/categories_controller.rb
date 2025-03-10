class CategoriesController < ApplicationController
  before_action :require_login
  before_action :set_category, only: [ :edit, :update, :destroy ]
  def index
    @categories = current_user.categories
  end

  def new
    @category = current_user.categories.build
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: "Category created successfully."
    else
      flash.now[:error] = @category.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end


  def edit;end

  def update
    if @category.update(category_params)
      flash[:notice] = "Category updated successfully."
      redirect_to categories_path
    else
      flash[:error] = @category.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    if @category.emails.any?
      flash[:error] = "Cannot delete category. Please delete associated emails first."
      redirect_to categories_path
    else
      @category.destroy
      flash[:success] = "Category deleted successfully."
      redirect_to categories_path
    end
  end

  def sync_emails
    service = GmailService.new(current_user)

    if service.fetch_unread_emails
      flash[:success] = "Emails synced successfully."
    else
      flash[:error] = service.error_message ||  "Failed to sync emails. Please try again."
    end

    respond_to do |format|
      format.html { redirect_to categories_path }
      format.js
    end
  rescue StandardError => e
    Rails.logger.error "Email Sync Error: #{e.message}"
    flash[:error] = "An error occurred while syncing emails."
    redirect_to categories_path
  end

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this page!"
      redirect_to root_path # Redirect to home page or login page
    end
  end

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
