require "openai"

class OpenAiService
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
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
