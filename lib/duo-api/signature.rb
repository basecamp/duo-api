require "base64"
require "duo-api/util"
require "duo-api/digesting"

# Parts of this code were derived from https://github.com/duosecurity/duo_ruby
# For Licensing see https://github.com/highrisehq/duo-api/blob/master/Duo-License
module DuoApi
  class Signature
    extend Util
    include Util
    include Digesting

    DUO_PREFIX  = 'TX'
    APP_PREFIX  = 'APP'
    AUTH_PREFIX = 'AUTH'


    DUO_EXPIRE = 300
    APP_EXPIRE = 3600

    ERR_USER = error_with_message('The user_key passed to sign with is invalid.')

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def sign(user_key)
      raise ERR_USER if !user_key || user_key.to_s.length == 0 if user_key.include?('|')
      if client.integration_key.to_s.length == 0 ||
          client.secret_key.to_s.length == 0 ||
          client.app_secret.to_s.length == 0
        raise InvalidConfiguration, "your DuoApi doesn't seem to be configured properly"
      end

      vals = [user_key.to_s, client.integration_key]

      duo_sig = sign_values(client.secret_key, vals, DUO_PREFIX, DUO_EXPIRE)
      app_sig = sign_values(client.app_secret, vals, APP_PREFIX, APP_EXPIRE)

      return [duo_sig, app_sig].join(':')
    end

    def verify(signed_response)
      auth_sig, app_sig = signed_response.to_s.split(':')
      auth_user = parse_vals(client.secret_key, auth_sig, AUTH_PREFIX)
      app_user = parse_vals(client.app_secret, app_sig, APP_PREFIX)

      return nil if auth_user != app_user

      return auth_user
    end

    private

      def parse_vals(key, val, prefix)
        ts = Time.now.to_i

        parts = val.to_s.split('|')
        return nil if parts.length != 3
        u_prefix, u_b64, u_sig = parts

        sig = digest(key, [u_prefix, u_b64].join('|'))
        sig = sig.to_s.strip
        u_sig = u_sig.to_s.strip

        return nil if digest(key, sig) != digest(key, u_sig)

        return nil if u_prefix != prefix

        cookie_parts = Base64.decode64(u_b64).to_s.split('|')
        return nil if cookie_parts.length != 3
        user, u_ikey, exp = cookie_parts

        return nil if u_ikey != client.integration_key

        return nil if ts >= exp.to_i

        return user
      end

      def sign_values(key, values, prefix, expiration)
        exp = Time.now.to_i + expiration

        val_list = values + [exp]
        val = val_list.join('|')

        b64 = Base64.encode64(val).gsub(/\n/,'')
        cookie = prefix + '|' + b64

        sig = digest(key, cookie)
        return [cookie, sig].join('|')
      end
  end
end
