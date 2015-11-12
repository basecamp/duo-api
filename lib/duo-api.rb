require "duo-api/version"
require "duo-api/configuration"
require "duo-api/signature"
require "duo-api/request"

module DuoApi
  def self.config
    @config ||= Configuration.new
    yield @config if block_given?
    @config
  end

  def self.get(path, options = {})
    Request.request(path, { :method => "GET" }.merge(options))
  end

  def self.post(path, options = {})
    Request.request(path, { :method => "POST" }.merge(options))
  end

  def self.sign(user_key)
    Signature.sign(user_key)
  end

  def self.verify(signed_response)
    Signature.verify(signed_response)
  end
end
