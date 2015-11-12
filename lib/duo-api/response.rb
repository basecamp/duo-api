require "json"

module DuoApi
  class Response
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def body
      @body ||=
        if json?
          JSON.parse(http_response.body)
        else
          raw_body
        end
    end

    def message
      if json?
        if body["response"] && body["response"]["status_msg"]
          body["response"]["status_msg"]
        elsif body["message"]
          body["message"]
        end
      end
    end

    def success?
      code == "200"
    end

    def unauthorized?
      code == "401"
    end

    def code
      http_response.code
    end

    def raw_body
      http_response.body
    end

    def content_type
      http_response.content_type
    end

    def json?
      content_type == "application/json"
    end

    def inspect
      inspects = "#<DuoApi::Response"
      inspects << " Content-Type:\"#{content_type}\""
      inspects << " Code:\"#{code}\""
      inspects << " Message:\"#{message}\""
      inspects << " Body:#{json? ? body.inspect : "\"#{body}\""}"
      inspects << ">"
      inspects
    end
  end
end
