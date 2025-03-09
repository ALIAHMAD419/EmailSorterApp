require "rails_helper"

RSpec.describe EmailSummarizer do
  let(:email_body) { "Hello, I hope you’re doing well. I wanted to follow up on our last conversation about the project timeline and deliverables." }
  let(:mock_summary) { "Follow-up on project timeline and deliverables." }

  let(:mock_ai_service) { instance_double(GeminiService) }

  before do
    allow(GeminiService).to receive(:new).and_return(mock_ai_service)
    allow(mock_ai_service).to receive(:chat).and_return(mock_summary)
  end

  describe ".summarize" do
    it "calls the AI service with the correct prompt" do
      prompt = "Summarize the following email in two concise lines:\n\n#{email_body}"

      EmailSummarizer.summarize(email_body)

      expect(mock_ai_service).to have_received(:chat).with(prompt)
    end

    it "returns the AI-generated summary" do
      result = EmailSummarizer.summarize(email_body)
      expect(result).to eq(mock_summary)
    end

    it "handles empty email bodies gracefully" do
      allow(mock_ai_service).to receive(:chat).and_return("No content available.")

      result = EmailSummarizer.summarize("")
      expect(result).to eq("No content available.")
    end
  end
end
