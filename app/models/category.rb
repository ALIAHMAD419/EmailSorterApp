class Category < ApplicationRecord
  validates :name, :description, presence: true
  belongs_to :user
end
