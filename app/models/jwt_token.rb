require 'jwt'
require 'base64'

class JwtToken < Struct.new(:token)
  class << self
    def encode(user, secret)
      payload = prepare_payload(user, secret)
      new JWT.encode(payload, secret)
    end

    private

    def prepare_payload(user, secret)
      iat = Time.now.to_i
      jti_raw = [secret, iat].join(':').to_s
      jti = Digest::MD5.hexdigest(jti_raw)
      { user_id: user.id, iat: iat, jti: jti }
    end
  end

  def decode
    return nil if token.blank?
    return nil if secret.blank?

    payload = JWT.decode(token, secret.token)
    payload.first
  end

  def to_s
    token
  end

  private

  def secret
    return @secret if defined? @secret
    @secret = JwtSecret.for_user(user_id) if user_id
  end

  def user_id
    return @user_id if defined? @user_id
    @user_id = decoded_payload['user_id']
  end

  def decoded_payload
    @decoded_payload ||= begin
      payload = token.split('.')
      if payload.size > 1
        payload = payload[1]
        payload += '=' * (4 - payload.length.modulo(4))
        payload = Base64.decode64(payload.tr('-_', '+/'))
        JSON.parse(payload)
      else
        {}
      end
    rescue JSON::ParserError
      {}
    end
  end
end
