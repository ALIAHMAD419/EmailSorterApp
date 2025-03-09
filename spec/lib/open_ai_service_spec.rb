require "rails_helper"
require "openai"

RSpec.describe OpenAiService do
  let(:service) { described_class.new }
  let(:client_double) { instance_double(OpenAI::Client) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(client_double)
  end

  describe "#chat" do
    let(:prompt) { "Hello, summarize this email." }

    context "when OpenAI API responds successfully" do
      let(:response_body) do
        {
          "choices" => [
            { "message" => { "content" => "Here is the summary of your email." } }
          ]
        }
      end

      before do
        allow(client_double).to receive(:chat).and_return(response_body)
      end

      it "returns the generated text" do
        result = service.chat(prompt)
        expect(result).to eq("Here is the summary of your email.")
      end
    end

    context "when OpenAI API returns a 404 error" do
      before do
        allow(client_double).to receive(:chat).and_raise(Faraday::ResourceNotFound.new("Not Found"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs an error and returns nil" do
        result = service.chat(prompt)
        expect(Rails.logger).to have_received(:error).with(/OpenAI API 404 Error/)
        expect(result).to be_nil
      end
    end

    context "when OpenAI API raises an unexpected error" do
      before do
        allow(client_double).to receive(:chat).and_raise(StandardError.new("Unexpected error"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and returns nil" do
        result = service.chat(prompt)
        expect(Rails.logger).to have_received(:error).with(/OpenAI API Error/)
        expect(result).to be_nil
      end
    end
  end
end
