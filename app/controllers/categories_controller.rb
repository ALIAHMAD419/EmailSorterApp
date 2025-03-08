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
      flash[:notice] = "Category created successfully."
      redirect_to categories_path
    else
      flash[:alert] = "Failed to create category. Please check the errors."
      render :new, status: :unprocessable_entity
    end
  end


  def edit;end

  def update
    if @category.update(category_params)
      flash[:notice] = "Category updated successfully."
      redirect_to categories_path
    else
      flash[:alert] = "Failed to update category. Please check the errors."
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @category.destroy
    flash[:success] = "Category deleted successfully."
    redirect_to categories_path
  end



  private

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page!"
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
