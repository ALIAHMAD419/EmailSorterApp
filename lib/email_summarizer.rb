require "openai"

class EmailSummarizer
  def self.summarize(email_body)
    # ai_service = OpenAiService.new
    ai_service = GeminiService.new
    prompt = "Summarize the following email in two concise lines:\n\n#{email_body}"
    ai_service.chat(prompt)
  end
end
