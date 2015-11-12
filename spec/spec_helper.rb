$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'duo-api'

DuoApi.config do |config|
  config.integration_key = "abc"
  config.secret_key = "xyz"
  config.hostname = "non-existent.example.com"
end
