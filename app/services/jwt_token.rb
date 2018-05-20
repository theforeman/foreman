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
      jti_raw = [secret, iat].join(':')
      jti = Digest::SHA256.hexdigest(jti_raw)
      { user_id: user.id, iat: iat, jti: jti }
    end

    def iat
      Time.now.to_i
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
    @secret = JwtSecret.find_by(user: user_id)
  end

  def user_id
    @user_id ||= decoded_payload['user_id']
  end

  # This method does not verify if the token signature is valid
  def decoded_payload
    @decoded_payload ||= JWT.decode(token, nil, false).first
  end
end
