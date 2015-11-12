require 'time'
module DuoApi
  class HeaderSignature
    include Util
    include Digesting

    attr_reader :client
    attr_reader :method
    attr_reader :path
    attr_reader :query_body_string

    def initialize(client, method, path, query_body_string)
      @client = client
      @method = method
      @path = path
      @query_body_string = query_body_string
    end

    def basic_auth
      username = client.integration_key
      password = digest(client.secret_key, body)

      [username, password]
    end

    def date_header
      @date_header ||= Time.now.utc.rfc2822
    end

    private

      def body
        components = [date_header]
        components << method
        components << client.hostname
        components << path
        components << query_body_string
        components.join("\n")
      end
  end
end
