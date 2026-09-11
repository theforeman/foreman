module Oidc
  class JwtVerifier
    CLOCK_SKEW = 60
    JWKS_CACHE_TTL = 1.hour

    def self.cache_key(auth_source_id)
      "oidc/jwks/#{auth_source_id}"
    end

    def initialize(auth_source)
      @auth_source = auth_source
      @http_client = Oidc::HttpClient.new(auth_source)
    end

    def decode(token, audience:)
      JWT.decode(token, nil, true,
        :algorithms => auth_source.allowed_algorithms,
        :aud => audience,
        :verify_aud => true,
        :iss => auth_source.oidc_issuer,
        :verify_iss => true,
        :leeway => CLOCK_SKEW,
        &key_finder)
        .first
    rescue JWT::VerificationError
      raise if @signature_retry

      @signature_retry = true
      Rails.cache.delete(jwks_cache_key)
      retry
    end

    def validate(jwks_uri: nil, force: false)
      Rails.cache.delete(jwks_cache_key) if force && auth_source.persisted?
      keys = jwks_uri ? load_jwks(jwks_uri) : jwks
      Rails.cache.write(jwks_cache_key, keys, :expires_in => JWKS_CACHE_TTL) if jwks_uri && auth_source.persisted?
      true
    end

    private

    attr_reader :auth_source, :http_client

    def key_finder
      lambda do |header|
        find_key(header)
      rescue JWT::DecodeError
        raise if @key_lookup_retry

        @key_lookup_retry = true
        Rails.cache.delete(jwks_cache_key)
        find_key(header)
      end
    end

    def find_key(header)
      finder = JWT::JWK::KeyFinder.new(:jwks => jwks)
      key = finder.key_for(header['kid']) if header['kid'].present?
      key ||= finder.key_for(header['x5t']) if header['x5t'].present?
      key
    end

    def jwks
      return load_jwks if auth_source.new_record?

      Rails.cache.fetch(jwks_cache_key, :expires_in => JWKS_CACHE_TTL) { load_jwks }
    end

    def load_jwks(jwks_uri = nil)
      response = http_client.get_json(jwks_uri || auth_source.metadata.fetch('jwks_uri'))
      keys = response['keys']
      raise Oidc::AuthenticationError, N_('The provider returned an invalid JSON Web Key Set') unless keys.is_a?(Array) && keys.present?

      { :keys => keys.map(&:symbolize_keys) }
    end

    def jwks_cache_key
      self.class.cache_key(auth_source.id)
    end
  end
end
