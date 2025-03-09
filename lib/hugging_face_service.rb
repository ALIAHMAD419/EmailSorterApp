require "hugging_face"
require "dotenv/load"

class HuggingFaceService
  def initialize
    @client = HuggingFace::InferenceApi.new(api_token: ENV["HUGGING_FACE_API_TOKEN"])
  end

  def chat(input)
    response = @client.text_generation(input: input)
    response["generated_text"] # Extract the generated text
  rescue Faraday::ResourceNotFound => e
    Rails.logger.error "Hugging Face API 404 Error: #{e.message}"
    nil
  rescue => e
    Rails.logger.error "Hugging Face API Error: #{e.message}"
    nil
  end
end
