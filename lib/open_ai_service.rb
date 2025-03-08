require "openai"

class OpenAiService
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(prompt)
    response = @client.chat(
      parameters: {
        model: "omni-moderation-2024-09-26",
        messages: [ { role: "user", content: prompt } ],
        max_tokens: 100
      }
    )
    response.dig("choices", 0, "message", "content") # Extract response text
  rescue Faraday::ResourceNotFound => e
    Rails.logger.error "OpenAI API 404 Error: #{e.message}"
    nil
  rescue => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    nil
  end
end



# model: "gpt-4o-mini",
