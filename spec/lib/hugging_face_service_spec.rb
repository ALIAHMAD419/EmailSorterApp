require "rails_helper"
require "hugging_face"

RSpec.describe HuggingFaceService do
  let(:hugging_face_api) { instance_double(HuggingFace::InferenceApi) }
  let(:service) { described_class.new }

  before do
    allow(HuggingFace::InferenceApi).to receive(:new).and_return(hugging_face_api)
  end

  describe "#chat" do
    let(:input_text) { "Tell me a joke." }

    context "when the API responds successfully" do
      it "returns the generated text" do
        response_body = { "generated_text" => "Why did the chicken cross the road? To get to the other side!" }
        allow(hugging_face_api).to receive(:text_generation).with(input: input_text).and_return(response_body)

        result = service.chat(input_text)

        expect(result).to eq(response_body["generated_text"])
      end
    end

    context "when the API returns a 404 error" do
      it "logs an error and returns nil" do
        allow(hugging_face_api).to receive(:text_generation).and_raise(Faraday::ResourceNotFound.new(nil))
        allow(Rails.logger).to receive(:error)

        result = service.chat(input_text)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Hugging Face API 404 Error/)
      end
    end

    context "when an unexpected API error occurs" do
      it "logs an error and returns nil" do
        allow(hugging_face_api).to receive(:text_generation).and_raise(StandardError.new("API timeout"))
        allow(Rails.logger).to receive(:error)

        result = service.chat(input_text)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Hugging Face API Error/)
      end
    end
  end
end
