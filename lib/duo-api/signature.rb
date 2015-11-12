require "duo-api/util"
require "duo-api/digesting"

module DuoApi
  class Signature
    extend Util
    extend Digesting

    DUO_PREFIX  = 'TX'
    APP_PREFIX  = 'APP'
    AUTH_PREFIX = 'AUTH'


    DUO_EXPIRE = 300
    APP_EXPIRE = 3600

    IKEY_LEN = 20
    SKEY_LEN = 40
    AKEY_LEN = 40

    ERR_USER = error_with_message('The user_key passed to sign is invalid.')
    ERR_IKEY = error_with_message('The Duo integration key passed is invalid.')
    ERR_SKEY = error_with_message('The Duo secret key is invalid.')
    ERR_AKEY = error_with_message("The application secret key must be at least #{AKEY_LEN} characters.")

    def self.sign(user_key)
      raise ERR_USER if !user_key || user_key.to_s.length == 0 if user_key.include?('|')
      raise ERR_AKEY if !config.app_secret || config.app_secret.to_s.length < AKEY_LEN

      vals = [user_key.to_s, config.integration_key]

      duo_sig = sign_values(config.secret_key, vals, DUO_PREFIX, DUO_EXPIRE)
      app_sig = sign_values(config.app_secret, vals, APP_PREFIX, APP_EXPIRE)

      return [duo_sig, app_sig].join(':')
    end

    def self.verify(signed_response)
      auth_sig, app_sig = signed_response.to_s.split(':')
      auth_user = parse_vals(config.secret_key, auth_sig, AUTH_PREFIX)
      app_user = parse_vals(config.app_secret, app_sig, APP_PREFIX)

      return nil if auth_user != app_user

      return auth_user
    end

    private

      def self.parse_vals(key, val, prefix)
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

        return nil if u_ikey != config.integration_key

        return nil if ts >= exp.to_i

        return user
      end

      def self.sign_values(key, values, prefix, expiration)
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
