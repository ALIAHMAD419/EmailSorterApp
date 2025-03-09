require "google/apis/gmail_v1"
require "base64"

class GmailService
  attr_reader :error_message
  def initialize(user, current_user)
    @current_user = current_user
    @user = user
    @service = Google::Apis::GmailV1::GmailService.new
    authorize!
  end

  def fetch_unread_emails
    return "No authorization" unless @service.authorization

    begin
      response = @service.list_user_messages("me", label_ids: ["INBOX"], q: "is:unread", max_results: 4)
      return "No unread emails found in the inbox" unless response.messages.present?

      json_data = JSON.pretty_generate(response.to_h)

      # Save the response in a file
      File.open(Rails.root.join("gmail.json"), "w") { |file| file.write(json_data) }

      response.messages.each do |message|
        begin
          process_email(message.id)
        rescue StandardError => e
          Rails.logger.error "⚠️ Skipping email (ID: #{message.id}) due to error: #{e.message}"
          next
        end
      end
      return "Successfully fetched unread emails."

    rescue Google::Apis::AuthorizationError
      Rails.logger.error "⚠️ Unauthorized! Checking login status..."
      return "Unauthorized! Please reauthenticate to continue."

    rescue StandardError => e
      Rails.logger.error "❌ Error fetching emails: #{e.message}"
      return "Error fetching emails: #{e.message}"
    end
  end
  



  def process_email(message_id)
    email = @service.get_user_message("me", message_id)
    subject = email.payload.headers.find { |h| h.name == "Subject" }&.value
    body =  EmailExtractor.extract_body(email)
    category = EmailCategorizer.categorize(body, @current_user.categories)
    summary = EmailSummarizer.summarize(body)

    if subject.blank? || body.blank? || category.blank? || summary.blank?
      raise "⚠️ Missing required email fields: subject=#{subject.inspect}, body=#{body.inspect}, category=#{category.inspect}, summary=#{summary.inspect}"
    end

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
    @service.authorization = @user.google_credentials[:token]
    if @service.authorization.nil?
      puts "⚠️ User is not logged in or credentials are missing!"
    end
  end

  def refresh_google_token!
    new_token = @user.google_credentials[:token]
    if new_token.nil?
      puts "⚠️ Token refresh failed. User must log in again."
      return false
    end

    authorize!
    true
  end
end
