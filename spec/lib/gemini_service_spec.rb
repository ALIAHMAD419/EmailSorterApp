require "rails_helper"
require "webmock/rspec"

RSpec.describe GeminiService do
  let(:gemini_service) { described_class.new }
  let(:api_url) { "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{ENV['GEMINI_API_KEY']}" }
  let(:prompt) { "Summarize the following email: Hello, how are you?" }
  let(:mock_response) do
    {
      "candidates" => [
        {
          "content" => {
            "parts" => [
              { "text" => "This is a summary of the email." }
            ]
          }
        }
      ]
    }.to_json
  end

  before do
    stub_request(:post, api_url)
      .with(
        body: {
          "contents": [{ "parts": [{ "text": prompt }] }]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
      .to_return(status: 200, body: mock_response, headers: {})
  end

  describe "#chat" do
    it "sends the correct request and returns a parsed response" do
      response = gemini_service.chat(prompt)

      expect(response).to eq("This is a summary of the email.")
      expect(WebMock).to have_requested(:post, api_url)
    end

    it "returns nil and logs an error if API call fails" do
      allow(Rails.logger).to receive(:error)

      stub_request(:post, api_url).to_return(status: 500, body: "Internal Server Error")

      response = gemini_service.chat(prompt)

      expect(response).to be_nil
      expect(Rails.logger).to have_received(:error).with(/Gemini API Error/)
    end
  end
end
