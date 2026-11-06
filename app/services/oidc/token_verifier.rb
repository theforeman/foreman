module Oidc
  class TokenVerifier
    CLOCK_SKEW = 60

    def initialize(auth_source)
      @auth_source = auth_source
      @jwt_verifier = Oidc::JwtVerifier.new(auth_source)
    end

    def verify(id_token, nonce, access_token = nil)
      payload = decode(id_token)
      validate_required_claims(payload)
      validate_authorized_party(payload)
      validate_nonce(payload, nonce)
      validate_access_token_hash(payload, id_token, access_token)
      payload
    rescue JWT::DecodeError => exception
      raise Oidc::AuthenticationError.new(N_('The OpenID Connect ID token is invalid: %s'), exception.message)
    end

    private

    attr_reader :auth_source, :jwt_verifier

    def decode(id_token)
      jwt_verifier.decode(id_token, :audience => auth_source.oidc_client_id)
    end

    def validate_required_claims(payload)
      %w[sub iss aud exp iat].each do |claim|
        raise Oidc::AuthenticationError.new(N_('The ID token is missing the %s claim'), claim) if payload[claim].blank?
      end
      unless payload['sub'].is_a?(String) && payload['sub'].bytesize <= OidcIdentity::SUBJECT_MAX_LENGTH
        raise Oidc::AuthenticationError, N_('The ID token subject is invalid')
      end
      unless valid_audience?(payload['aud'])
        raise Oidc::AuthenticationError, N_('The ID token audience is invalid')
      end
      unless payload['exp'].is_a?(Numeric) && payload['iat'].is_a?(Numeric)
        raise Oidc::AuthenticationError, N_('The ID token timestamps are invalid')
      end
      if payload['iat'] > Time.now.utc.to_i + CLOCK_SKEW
        raise Oidc::AuthenticationError, N_('The ID token was issued in the future')
      end
    end

    def validate_authorized_party(payload)
      audiences = Array(payload['aud'])
      return unless audiences.length > 1 || payload['azp'].present?
      return if secure_compare(payload['azp'], auth_source.oidc_client_id)

      raise Oidc::AuthenticationError, N_('The ID token authorized party is invalid')
    end

    def validate_nonce(payload, expected_nonce)
      return if secure_compare(payload['nonce'], expected_nonce)

      raise Oidc::AuthenticationError, N_('The ID token nonce is invalid')
    end

    def validate_access_token_hash(payload, id_token, access_token)
      return if payload['at_hash'].blank?
      raise Oidc::AuthenticationError, N_('The ID token contains at_hash without an access token') if access_token.blank?

      algorithm = JWT.decode(id_token, nil, false).last.fetch('alg')
      digest_bits = algorithm[/\d+\z/]
      raise Oidc::AuthenticationError, N_('The ID token uses an unsupported hash algorithm') unless %w[256 384 512].include?(digest_bits)

      digest_name = "SHA#{digest_bits}"
      digest = OpenSSL::Digest.new(digest_name).digest(access_token)
      expected = Base64.urlsafe_encode64(digest.first(digest.bytesize / 2), :padding => false)
      return if secure_compare(payload['at_hash'], expected)

      raise Oidc::AuthenticationError, N_('The ID token access token hash is invalid')
    rescue KeyError, OpenSSL::Digest::DigestError
      raise Oidc::AuthenticationError, N_('The ID token uses an unsupported hash algorithm')
    end

    def secure_compare(left, right)
      left.is_a?(String) && right.is_a?(String) && left.present? && right.present? &&
        left.bytesize == right.bytesize && ActiveSupport::SecurityUtils.secure_compare(left, right)
    end

    def valid_audience?(audience)
      audience.is_a?(String) || (audience.is_a?(Array) && audience.present? && audience.all? { |value| value.is_a?(String) })
    end
  end
end
