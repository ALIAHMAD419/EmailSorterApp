class CategoriesController < ApplicationController
  before_action :require_login
  before_action :set_category, only: [ :edit, :update, :destroy ]
  skip_before_action :verify_authenticity_token, only: [ :sync_emails ]


  def index
    @categories = current_user.categories
    @user_children = current_user.children
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
    user_ids = params[:user_ids] || []
    errors = []
    successes = 0


    user_ids.each do |user_id|
      user = User.find_by(id: user_id)

      unless user
        errors << "User with ID #{user_id} not found."
        next
      end

      required_fields = [ user.google_token, user.google_token_expires_at, user.uid, user.provider ]

      unless required_fields.all?(&:present?)
        errors << "User #{user.email} is missing required authentication credentials."
        next
      end
      service = GmailService.new(user, current_user)

      begin
        message = service.fetch_unread_emails
        if message == "Successfully fetched unread emails."
          successes += 1
          flash[:notice] = message # Success message
        else
          errors << message # Error or info message
        end
      rescue StandardError => e
        Rails.logger.error "Email Sync Error: #{e.message}"
        errors << "An error occurred while syncing emails."
      end
    end

    if successes.positive?
      flash[:success] = "#{successes} user(s) emails synced successfully."
    end

    if errors.any?
      flash[:error] = errors.join(" ")
    end

    respond_to do |format|
      format.html { redirect_to categories_path }
      format.js
    end
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
