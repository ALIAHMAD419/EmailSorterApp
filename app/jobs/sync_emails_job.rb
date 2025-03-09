class SyncEmailsJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      service = GmailService.new(user)
      if service.fetch_unread_emails
        Rails.logger.info "Emails synced successfully for user #{user.id}."
      else
        Rails.logger.error "Failed to sync emails for user #{user.id}: #{service.error_message}"
      end
    rescue StandardError => e
      Rails.logger.error "Email Sync Error for user #{user.id}: #{e.message}"
    end
  end
end
