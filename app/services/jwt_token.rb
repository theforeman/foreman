require 'jwt'
require 'base64'

class JwtToken < Struct.new(:token)
  class << self
    def encode(user, secret, expiration: nil, scope: [])
      payload = prepare_payload(user, secret, expiration: expiration, scope: scope)
      new JWT.encode(payload, secret)
    end

    private

    def prepare_payload(user, secret, expiration: nil, scope: [])
      jti_raw = [secret, iat].join(':')
      jti = Digest::SHA256.hexdigest(jti_raw)
      payload = {
        user_id: user.id,
        iat: iat,
        jti: jti,
      }

      payload[:exp] = (Time.now.to_i + expiration) if expiration
      payload[:scope] = format_scope(scope) if scope.any?
      payload
    end

    def iat
      Time.now.to_i
    end

    # Format scope to string 'controller#action1 controller#action2'
    def format_scope(scope)
      scope.map { |sc| sc[:actions].map { |action| "#{sc[:controller]}##{action}" }.join(' ') }.join(' ')
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

  # This method does not verify if the token signature is valid
  # defined? keyword checks if expression is currently defined. It
  # therefore, helps to memoize the nil JWT values.
  def decoded_payload
    return @decoded_payload if defined?(@decoded_payload)
    @decoded_payload = JWT.decode(token, nil, false).first

    unless @decoded_payload.is_a?(Hash)
      logger.error "Invalid decoded JWT format."
      logger.debug "Received payload: #{@decoded_payload}"
      @decoded_payload = nil
    end
    @decoded_payload
  rescue JWT::DecodeError => e
    Foreman::Logging.exception('Failed to decode JWT', e)
    @decoded_payload = nil
  end

  private

  def secret
    return @secret if defined? @secret
    @secret = JwtSecret.find_by(user: user_id)
  end

  def user_id
    @user_id ||= decoded_payload.try(:[], 'user_id')
  end
end
