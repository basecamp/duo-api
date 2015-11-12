module DuoApi
  class Configuration < Struct.new(:hostname, :integration_key, :secret_key, :app_secret)
  end
end
