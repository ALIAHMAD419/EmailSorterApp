require "rails_helper"
require "google/apis/gmail_v1"
require "webmock/rspec"

RSpec.describe GmailService do
  let(:user) { create(:user) }
  let(:gmail_service) { described_class.new(user) }
  let(:gmail_api) { instance_double(Google::Apis::GmailV1::GmailService) }
  let(:email_response) do
    instance_double(
      Google::Apis::GmailV1::ListMessagesResponse,
      messages: [ instance_double(Google::Apis::GmailV1::Message, id: "12345") ]
    )
  end

  let(:email_double) do
    instance_double(
      Google::Apis::GmailV1::Message,
      id: "12345",
      payload: instance_double(
        Google::Apis::GmailV1::MessagePart,
        headers: [ instance_double(Google::Apis::GmailV1::MessagePartHeader, name: "Subject", value: "Test Subject") ]
      )
    )
  end

  before do
    allow(user).to receive(:google_credentials).and_return(double)
    allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(gmail_api)
    allow(gmail_api).to receive(:authorization).and_return(double)
    allow(gmail_api).to receive(:authorization=)
    allow(email_response).to receive(:to_h).and_return({})
    allow(gmail_api).to receive(:list_user_messages).and_return(email_response)

    # ✅ Now email_double is defined!
    allow(gmail_api).to receive(:get_user_message).with("me", "12345").and_return(email_double)
  end



  describe "#fetch_unread_emails" do
    context "when user is unauthorized" do
      before do
        allow(gmail_api).to receive(:list_user_messages).and_raise(Google::Apis::AuthorizationError.new("Unauthorized"))
        allow(gmail_service).to receive(:refresh_google_token!).and_return(false)
      end
    end
  end

  describe "#process_email" do
    let(:email_message) do
      instance_double(
        Google::Apis::GmailV1::Message,
        id: "12345",
        payload: instance_double(
          Google::Apis::GmailV1::MessagePart,
          headers: [ instance_double(Google::Apis::GmailV1::MessagePartHeader, name: "Subject", value: "Test Subject") ]
        )
      )
    end

    before do
      allow(gmail_api).to receive(:get_user_message).and_return(email_message)
      allow(EmailExtractor).to receive(:extract_body).and_return("Email body")
      allow(EmailCategorizer).to receive(:categorize).and_return(create(:category, user: user))
      allow(EmailSummarizer).to receive(:summarize).and_return("Summary text")
      allow(Email).to receive(:create!)
      allow(gmail_service).to receive(:archive_email)
    end

    it "processes an email and saves it to the database" do
      gmail_service.process_email("12345")

      expect(gmail_api).to have_received(:get_user_message).with("me", "12345")
      expect(EmailExtractor).to have_received(:extract_body).with(email_message)
      expect(EmailCategorizer).to have_received(:categorize).with("Email body", user.categories)
      expect(EmailSummarizer).to have_received(:summarize).with("Email body")
      expect(Email).to have_received(:create!)
      expect(gmail_service).to have_received(:archive_email).with("12345")
    end
  end

  describe "#archive_email" do
    it "removes the email from the inbox" do
      allow(gmail_api).to receive(:modify_message)

      gmail_service.archive_email("12345")

      expect(gmail_api).to have_received(:modify_message).with("me", "12345", instance_of(Google::Apis::GmailV1::ModifyMessageRequest))
    end
  end
end
