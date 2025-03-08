require "openai"

class EmailCategorizer
  DEFAULT_CATEGORY_NAME = "Uncategorized".freeze

  def self.categorize(email_body)
    # email_body = File.read("body.txt")

    return default_category if email_body.blank?

    categories = Category.all #has to add cuurent user
    return default_category if categories.empty?

    ai_service = OpenAiService.new
    prompt = <<~PROMPT
      You are an AI email categorizer. Below is an email body. Your task is to assign the best-matching category from the list below based on its description.

      Email Content:
      #{email_body}

      Available Categories:
      #{categories.map { |c| "#{c.name}: #{c.description}" }.join("\n")}

      Respond ONLY with the exact name of the best category not the description. If no category matches, respond with "#{DEFAULT_CATEGORY_NAME}".
    PROMPT
    category_name = ai_service.chat(prompt)

    matched_category = categories.find { |c| c.name.downcase == category_name.downcase } if category_name.present?

    matched_category || default_category
  end

  def self.default_category
    Category.find_or_create_by(name: DEFAULT_CATEGORY_NAME, description: "Emails that don't fit other categories.")
  end
end
