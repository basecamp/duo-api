require 'time'
module DuoApi
  class HeaderSignature
    extend Util
    include Util
    include Digesting

    attr_reader :method
    attr_reader :path
    attr_reader :query_body_string

    def initialize(method, path, query_body_string)
      @method = method
      @path = path
      @query_body_string = query_body_string
    end

    def basic_auth
      username = DuoApi.config.integration_key
      password = digest(config.secret_key, body)

      [username, password]
    end

    def date_header
      @date_header ||= Time.now.utc.rfc2822
    end

    private

      def body
        components = [date_header]
        components << method
        components << hostname
        components << path
        components << query_body_string
        components.join("\n")
      end

      def hostname
        DuoApi.config.hostname
      end
  end
end
