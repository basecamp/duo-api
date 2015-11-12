module DuoApi
  module Util
    DuoApiError = Class.new(StandardError)

    def stringify_hash(hash)
      hash ||= {}
      Hash[hash.map { |k, v| [k.to_s, v] }]
    end

    def error_with_message(message)
      klass = Class.new(DuoApiError)
      klass.send :define_method, :initialize do |*msg|
        msg = msg.first
        msg ||= message
        super msg
      end
      klass
    end
  end
end
