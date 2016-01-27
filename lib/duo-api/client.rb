module DuoApi
  class Client
    ATTRIBUTES = %w[
      integration_key
      secret_key
      app_secret
      hostname
    ]
    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    def initialize(options = {})
      options.each do |key, value|
        if ATTRIBUTES.include?(key.to_s)
          instance_variable_set("@#{key}", value)
        else
          raise ArgumentError, "no attribute #{key}"
        end
      end
    end

    def get(path, options = {})
      Request.request(self, path, { :method => "GET" }.merge(options))
    end

    def post(path, options = {})
      Request.request(self, path, { :method => "POST" }.merge(options))
    end

    def delete(path, options = {})
      Request.request(self, path, { :method => "DELETE" }.merge(options))
    end

    def sign(user_key)
      signer.sign(user_key)
    end

    def verify(signed_response)
      signer.verify(signed_response)
    end

    private

      def signer
        Signature.new(self)
      end
  end
end
