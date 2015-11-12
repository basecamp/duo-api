require "duo-api/version"
require "duo-api/client"
require "duo-api/signature"
require "duo-api/request"

if RUBY_VERSION =~ /1\.8/
  begin
    require "json"
  rescue
    raise "you need to install the json Gem for Ruby 1.8.7"
  end
end

module DuoApi
  InvalidConfiguration = Class.new(StandardError)

  def self.config
    @config ||= Client.new
    yield @config if block_given?
    @config
  end
  class << self
    alias client config
  end

  def self.get(*args)
    client.get(*args)
  end

  def self.post(*args)
    client.post(*args)
  end

  def self.request(*args)
    client.request(*args)
  end

  def self.sign(*args)
    client.sign(*args)
  end

  def self.verify(*args)
    client.verify(*args)
  end
end
