require "rails_helper"
require "google/apis/gmail_v1"

RSpec.describe EmailExtractor do
  let(:plain_text_content) { "This is a plain text email." }
  let(:html_content) { "<html><body><p>This is an <b>HTML</b> email.</p></body></html>" }
  let(:base64_plain_text) { Base64.urlsafe_encode64(plain_text_content) }
  let(:base64_html_text) { Base64.urlsafe_encode64(html_content) }

  let(:plain_text_part) do
    instance_double(Google::Apis::GmailV1::MessagePart,
                    mime_type: "text/plain",
                    body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: base64_plain_text))
  end

  let(:html_part) do
    instance_double(Google::Apis::GmailV1::MessagePart,
                    mime_type: "text/html",
                    body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: base64_html_text))
  end

  let(:multipart_email) do
    instance_double(Google::Apis::GmailV1::Message,
                    payload: instance_double(Google::Apis::GmailV1::MessagePart, parts: [ plain_text_part, html_part ]))
  end

  let(:single_part_email) do
    instance_double(Google::Apis::GmailV1::Message,
                    payload: instance_double(Google::Apis::GmailV1::MessagePart, mime_type: "text/plain",
                                             body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: base64_plain_text)))
  end

  let(:empty_email) { instance_double(Google::Apis::GmailV1::Message, payload: nil) }

  describe ".extract_body" do
    context "when email has both plain text and HTML" do
      it "extracts and returns cleaned HTML content" do
        result = EmailExtractor.extract_body(multipart_email)
        expect(result).to eq("This is an HTML email.")
      end
    end

    context "when email has no payload" do
      it "returns an empty string" do
        result = EmailExtractor.extract_body(empty_email)
        expect(result).to eq("")
      end
    end

    context "when email has malformed base64 content" do
      let(:malformed_part) do
        instance_double(Google::Apis::GmailV1::MessagePart,
                        mime_type: "text/plain",
                        body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: "malformed_base64"))
      end

      let(:malformed_email) do
        instance_double(Google::Apis::GmailV1::Message,
                        payload: instance_double(Google::Apis::GmailV1::MessagePart, parts: [ malformed_part ]))
      end
    end
  end

  describe ".clean_html" do
    it "removes scripts and styles from HTML content" do
      html_with_scripts = '<html><head><style>.hidden { display: none; }</style></head><body><script>alert("hacked");</script><p>Safe Content</p></body></html>'
      result = EmailExtractor.send(:clean_html, html_with_scripts)
      expect(result).to eq("Safe Content")
    end

    it "returns empty string if HTML content is nil or empty" do
      expect(EmailExtractor.send(:clean_html, nil)).to eq("")
      expect(EmailExtractor.send(:clean_html, "")).to eq("")
    end
  end
end
