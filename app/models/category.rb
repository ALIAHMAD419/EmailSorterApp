class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false, message: "already exists!" }
  validates :description, presence: true
  belongs_to :user
  has_many :emails
end
