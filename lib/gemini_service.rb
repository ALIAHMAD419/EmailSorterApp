require "net/http"
require "uri"
require "json"

class GeminiService
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
  API_KEY = ENV["GEMINI_API_KEY"] # Set your API key in environment variables

  def initialize
    @uri = URI.parse("#{API_URL}?key=#{API_KEY}")
  end

  def chat(prompt)
    request = Net::HTTP::Post.new(@uri)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
      "contents": [ { "parts": [ { "text": prompt } ] } ]
    })

    response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    parsed_response = JSON.parse(response.body)
    parsed_response.dig("candidates", 0, "content", "parts", 0, "text").strip
  rescue => e
    Rails.logger.error "Gemini API Error: #{e.message}"
    nil
  end
end
