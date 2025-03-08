require "google/apis/gmail_v1"
require "base64"

class GmailService
  def initialize(user)
    @user = user
    @service = Google::Apis::GmailV1::GmailService.new
    authorize!
  end

  def fetch_unread_emails
    return unless @service.authorization

    begin
      response = @service.list_user_messages("me", label_ids: [ "INBOX" ], q: "is:unread", max_results: 3)
      return unless response.messages
      json_data = JSON.pretty_generate(response.to_h)

      # Save the response in a file
      File.open(Rails.root.join("gmail.json"), "w") { |file| file.write(json_data) }

      response.messages.each do |message|
        process_email(message.id)
      end
    rescue Google::Apis::AuthorizationError
      puts "⚠️ Unauthorized! Checking login status..."
      return unless refresh_google_token!

      puts "🔄 Retrying email fetch..."
      retry
    rescue StandardError => e
      puts "❌ Error fetching emails: #{e.message}"
    end
  end


  def process_email(message_id)
    email = @service.get_user_message("me", message_id)
    subject = email.payload.headers.find { |h| h.name == "Subject" }&.value
    body =  EmailExtractor.extract_body(email)
    category = EmailCategorizer.categorize(body)
    summary = EmailSummarizer.summarize(body)

    Email.create!(
      subject: subject,
      body: body,
      summary: summary,
      gmail_message_id: message_id,
      category: category,
      user: @user
    )
    archive_email(message_id)
  end

  def archive_email(message_id)
    @service.modify_message("me", message_id, Google::Apis::GmailV1::ModifyMessageRequest.new(remove_label_ids: [ "INBOX" ]))
  end

  private

  def authorize!
    @service.authorization = @user.google_credentials
    if @service.authorization.nil?
      puts "⚠️ User is not logged in or credentials are missing!"
    end
  end

  def refresh_google_token!
    new_token = @user.google_credentials
    if new_token.nil?
      puts "⚠️ Token refresh failed. User must log in again."
      return false
    end

    authorize!
    true
  end
end
