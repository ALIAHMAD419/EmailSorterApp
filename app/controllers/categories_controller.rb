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
      render :new
    end
  end

  def edit;end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Category deleted successfully."
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
