class Email < ApplicationRecord
  belongs_to :category
  belongs_to :user
  validates :subject, :body, :summary, :category, :gmail_message_id, presence: true
end
