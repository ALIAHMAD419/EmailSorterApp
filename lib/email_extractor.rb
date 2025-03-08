require "base64"
require "nokogiri"

class EmailExtractor
  def self.extract_body(email)
    return "" unless email.payload

    parts = email.payload.parts || [ email.payload ] # If no parts, it's a single-part email
    html_body, text_body = nil, nil

    parts.each do |part|
      mime_type = part.mime_type
      body_data = part.body&.data

      next unless body_data # Skip empty parts

      decoded_body = safe_base64_decode(body_data)

      case mime_type
      when "text/plain"
        text_body = decoded_body unless text_body # Prefer HTML, but fallback to plain text
      when "text/html"
        html_body = decoded_body
      end
    end

    clean_html(html_body || text_body || "")
  end

  private

  # Safe Base64 decoding with error handling
  def self.safe_base64_decode(data)
    return "" if data.nil? || data.empty?

    begin
      Base64.urlsafe_decode64(data)
    rescue ArgumentError
      data # Return original string if decoding fails
    end
  end

  def self.clean_html(html)
    return "" if html.nil? || html.empty?

    document = Nokogiri::HTML(html)

    # Remove scripts and styles
    document.search("script, style").remove

    # Convert HTML to clean text
    document.text.strip
  end
end
