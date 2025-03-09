require "rails_helper"

RSpec.describe Category, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      category = build(:category, user: user)
      expect(category).to be_valid
    end

    it "is invalid without a name" do
      category = build(:category, name: nil, user: user)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a description" do
      category = build(:category, description: nil, user: user)
      expect(category).not_to be_valid
      expect(category.errors[:description]).to include("can't be blank")
    end

    it "enforces uniqueness of name scoped to user" do
      create(:category, name: "Work", user: user)
      duplicate_category = build(:category, name: "Work", user: user)

      expect(duplicate_category).not_to be_valid
      expect(duplicate_category.errors[:name]).to include("already exists!")
    end

    it "allows duplicate names for different users" do
      another_user = create(:user)
      create(:category, name: "Work", user: user)
      category = build(:category, name: "Work", user: another_user)

      expect(category).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:emails) }
  end
end
