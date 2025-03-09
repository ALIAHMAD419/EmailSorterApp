require 'rails_helper'

describe EmailsController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:email) { create(:email, category: category, user: user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:logged_in?).and_return(true)
  end

  describe "GET #index" do
    context "when category_id is present" do
      it "assigns emails of the category" do
        get :index, params: { category_id: category.id }
        expect(assigns(:emails)).to eq(category.emails)
      end

      it "redirects with alert if category is not found" do
        get :index, params: { category_id: 9999 }
        expect(response).to redirect_to(categories_path)
        expect(flash[:alert]).to eq("Category not found")
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested email" do
      get :show, params: { category_id: category.id, id: email.id }
      expect(assigns(:email)).to eq(email)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the email and redirects" do
      email
      expect {
        delete :destroy, params: { category_id: category.id, id: email.id }
      }.to change(Email, :count).by(-1)
      expect(response).to redirect_to(category_emails_path)
      expect(flash[:success]).to eq("Email deleted successfully.")
    end
  end

  describe "POST #bulk_action" do
    let!(:emails) { create_list(:email, 3, category: category, user: user) }

    context "when deleting emails" do
      it "deletes selected emails" do
        expect {
          post :bulk_action, params: { action_type: "delete", email_ids: emails.map(&:id) }
        }.to change(Email, :count).by(-3)
        expect(flash[:success]).to eq("Selected emails have been deleted.")
      end
    end

    context "when no emails are selected" do
      it "sets an error flash message" do
        post :bulk_action, params: { action_type: "delete", email_ids: [] }
        expect(flash[:error]).to eq("No emails selected.")
      end
    end

    context "when unsubscribing emails" do
      it "sets an info flash message" do
        post :bulk_action, params: { action_type: "unsubscribe", email_ids: emails.map(&:id) }
        expect(flash[:info]).to eq("Unsubscribe action is in progresss.")
      end
    end

    context "when an invalid action is selected" do
      it "sets an error flash message" do
        post :bulk_action, params: { action_type: "invalid", email_ids: emails.map(&:id) }
        expect(flash[:error]).to eq("Invalid action selected.")
      end
    end
  end
end
