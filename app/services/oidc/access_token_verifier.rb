module Oidc
  class AccessTokenVerifier
    def initialize(auth_source)
      @auth_source = auth_source
      @jwt_verifier = Oidc::JwtVerifier.new(auth_source)
    end

    def verify(token)
      payload = jwt_verifier.decode(token, :audience => auth_source.api_audiences)
      %w[sub iss aud exp iat].each do |claim|
        raise Oidc::AuthenticationError.new(N_('The access token is missing the %s claim'), claim) if payload[claim].blank?
      end
      unless payload['sub'].is_a?(String) && payload['sub'].bytesize <= OidcIdentity::SUBJECT_MAX_LENGTH
        raise Oidc::AuthenticationError, N_('The access token subject is invalid')
      end
      audience = payload['aud']
      unless audience.is_a?(String) || (audience.is_a?(Array) && audience.present? && audience.all? { |value| value.is_a?(String) })
        raise Oidc::AuthenticationError, N_('The access token audience is invalid')
      end
      unless payload['exp'].is_a?(Numeric) && payload['iat'].is_a?(Numeric)
        raise Oidc::AuthenticationError, N_('The access token timestamps are invalid')
      end
      if payload['iat'] > Time.now.utc.to_i + Oidc::JwtVerifier::CLOCK_SKEW
        raise Oidc::AuthenticationError, N_('The access token was issued in the future')
      end
      payload
    rescue JWT::DecodeError => exception
      raise Oidc::AuthenticationError.new(N_('The OpenID Connect access token is invalid: %s'), exception.message)
    end

    private

    attr_reader :auth_source, :jwt_verifier
  end
end
