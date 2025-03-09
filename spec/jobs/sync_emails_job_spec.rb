require 'rails_helper'

RSpec.describe SyncEmailsJob, type: :job do
  let!(:user) { create(:user) } # Creates a test user

  before do
    allow(GmailService).to receive(:new).and_return(double(fetch_unread_emails: true, error_message: nil))
    allow(Rails.logger).to receive(:info).and_call_original
    allow(Rails.logger).to receive(:error).and_call_original
  end

  it 'calls GmailService for each user and logs success' do
    expect(Rails.logger).to receive(:info).with(/Emails synced successfully for user \d+/)
    SyncEmailsJob.perform_now
  end

  it 'handles exceptions and logs an error' do
    allow(GmailService).to receive(:new).and_raise(StandardError.new("Unexpected Error"))

    expect(Rails.logger).to receive(:error).with(/Email Sync Error for user \d+: Unexpected Error/)
    SyncEmailsJob.perform_now
  end
end
