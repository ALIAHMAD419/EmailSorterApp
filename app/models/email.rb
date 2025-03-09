class Email < ApplicationRecord
  belongs_to :category
  belongs_to :user
  validates :body, :summary, :gmail_message_id, presence: true
end
