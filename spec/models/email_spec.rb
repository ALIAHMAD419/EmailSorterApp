require "rails_helper"

RSpec.describe Email, type: :model do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }

  describe "validations" do
    it "is valid with valid attributes" do
      email = build(:email, user: user, category: category)
      expect(email).to be_valid
    end

    it "is invalid without a body" do
      email = build(:email, body: nil, user: user, category: category)
      expect(email).not_to be_valid
      expect(email.errors[:body]).to include("can't be blank")
    end

    it "is invalid without a summary" do
      email = build(:email, summary: nil, user: user, category: category)
      expect(email).not_to be_valid
      expect(email.errors[:summary]).to include("can't be blank")
    end

    it "is invalid without a gmail_message_id" do
      email = build(:email, gmail_message_id: nil, user: user, category: category)
      expect(email).not_to be_valid
      expect(email.errors[:gmail_message_id]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end
end
