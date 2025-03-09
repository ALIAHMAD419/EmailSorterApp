require "rails_helper"

RSpec.describe EmailCategorizer do
  let!(:default_category) { create(:category, name: "Default", description: "Emails that don't fit other categories.") }
  let!(:work_category) { create(:category, name: "Work", description: "Emails related to work") }
  let!(:promo_category) { create(:category, name: "Promotions", description: "Promotional emails") }
  let!(:categories) { [ work_category, promo_category ] }

  describe ".categorize" do
    context "when email body is blank" do
      it "returns the default category" do
        expect(EmailCategorizer.categorize("", categories)).to eq(default_category)
      end
    end

    context "when no categories are available" do
      it "returns the default category" do
        expect(EmailCategorizer.categorize("This is an email body", [])).to eq(default_category)
      end
    end

    context "when AI matches a category" do
      before do
        allow_any_instance_of(GeminiService).to receive(:chat).and_return("Work")
      end

      it "returns the matched category" do
        result = EmailCategorizer.categorize("Project meeting update", categories)
        expect(result).to eq(work_category)
      end
    end

    context "when AI does not match any category" do
      before do
        allow_any_instance_of(GeminiService).to receive(:chat).and_return("Unknown Category")
      end

      it "returns the default category" do
        result = EmailCategorizer.categorize("Some random email content", categories)
        expect(result).to eq(default_category)
      end
    end

    context "when AI returns nil" do
      before do
        allow_any_instance_of(GeminiService).to receive(:chat).and_return(nil)
      end

      it "returns the default category" do
        result = EmailCategorizer.categorize("Important email", categories)
        expect(result).to eq(default_category)
      end
    end
  end

  describe ".default_category" do
    it "finds or creates the default category" do
      expect(EmailCategorizer.default_category).to eq(default_category)
    end
  end
end
