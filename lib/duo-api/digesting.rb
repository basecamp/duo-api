require 'openssl'
module DuoApi
  module Digesting
    DIGEST = OpenSSL::Digest.new("sha1")

    def digest(key, text)
      OpenSSL::HMAC.hexdigest(DIGEST, key, text)
    end
  end
end
