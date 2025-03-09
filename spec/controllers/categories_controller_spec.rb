require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:logged_in?).and_return(true)
  end

  describe "GET #index" do
    it "assigns @categories" do
      get :index
      expect(assigns(:categories)).to eq(user.categories)
    end
  end

  describe "GET #new" do
    it "assigns a new category" do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new category" do
        expect {
          post :create, params: { category: { name: "Test Category", description: "A test category" } }
        }.to change(Category, :count).by(1)
      end

      it "redirects to categories_path with success message" do
        post :create, params: { category: { name: "Test Category", description: "A test category" } }
        expect(response).to redirect_to(categories_path)
        expect(flash[:notice]).to eq("Category created successfully.")
      end
    end

    context "with invalid attributes" do
      it "renders :new with error message" do
        post :create, params: { category: { name: "", description: "" } }
        expect(response).to render_template(:new)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested category" do
      get :edit, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the category" do
        patch :update, params: { id: category.id, category: { name: "Updated Name" } }
        expect(category.reload.name).to eq("Updated Name")
        expect(flash[:notice]).to eq("Category updated successfully.")
        expect(response).to redirect_to(categories_path)
      end
    end

    context "with invalid attributes" do
      it "does not update and re-renders edit" do
        patch :update, params: { id: category.id, category: { name: "" } }
        expect(category.reload.name).not_to eq("")
        expect(response).to render_template(:edit)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    context "when category has emails" do
      before { create(:email, category: category, user: user) }
      
      it "does not delete the category and shows error" do
        delete :destroy, params: { id: category.id }
        expect(Category.exists?(category.id)).to be_truthy
        expect(flash[:error]).to eq("Cannot delete category. Please delete associated emails first.")
      end
    end

    context "when category has no emails" do
      it "deletes the category" do
        delete :destroy, params: { id: category.id }
        expect(Category.exists?(category.id)).to be_falsey
        expect(flash[:success]).to eq("Category deleted successfully.")
      end
    end
  end

  describe "POST #sync_emails" do
    let(:gmail_service) { instance_double(GmailService) }

    before do
      allow(GmailService).to receive(:new).with(user).and_return(gmail_service)
    end

    context "when emails are synced successfully" do
      it "sets a success message" do
        allow(gmail_service).to receive(:fetch_unread_emails).and_return(true)
        post :sync_emails
        expect(flash[:success]).to eq("Emails synced successfully.")
        expect(response).to redirect_to(categories_path)
      end
    end

    context "when email sync fails" do
      it "sets an error message" do
        allow(gmail_service).to receive(:fetch_unread_emails).and_return(false)
        allow(gmail_service).to receive(:error_message).and_return("Sync failed")
        post :sync_emails
        expect(flash[:error]).to eq("Sync failed")
        expect(response).to redirect_to(categories_path)
      end
    end
  end
end
