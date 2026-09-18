module Oidc
  class ProviderMetadata
    REQUIRED_ENDPOINTS = %w[authorization_endpoint token_endpoint jwks_uri].freeze
    OPTIONAL_ENDPOINTS = %w[userinfo_endpoint end_session_endpoint].freeze
    CACHE_TTL = 1.hour

    def self.cache_key(auth_source_id)
      "oidc/provider_metadata/#{auth_source_id}"
    end

    def initialize(auth_source)
      @auth_source = auth_source
      @http_client = Oidc::HttpClient.new(auth_source)
    end

    def fetch(force: false)
      return validate(manual_metadata) unless auth_source.oidc_use_discovery?
      return discover if auth_source.new_record? || force

      Rails.cache.fetch(self.class.cache_key(auth_source.id), :expires_in => CACHE_TTL, :force => force) do
        discover
      end
    end

    private

    attr_reader :auth_source, :http_client

    def discover
      issuer = auth_source.oidc_issuer.delete_suffix('/')
      metadata = http_client.get_json("#{issuer}/.well-known/openid-configuration")
      unless secure_compare(metadata['issuer'], auth_source.oidc_issuer)
        raise Oidc::ConfigurationError, N_('Discovered issuer does not match the configured issuer')
      end

      validate(metadata)
    end

    def manual_metadata
      {
        'issuer' => auth_source.oidc_issuer,
        'authorization_endpoint' => auth_source.oidc_authorization_endpoint,
        'token_endpoint' => auth_source.oidc_token_endpoint,
        'userinfo_endpoint' => auth_source.oidc_userinfo_endpoint,
        'jwks_uri' => auth_source.oidc_jwks_uri,
        'end_session_endpoint' => auth_source.oidc_end_session_endpoint,
      }.compact
    end

    def validate(metadata)
      REQUIRED_ENDPOINTS.each do |endpoint|
        raise Oidc::ConfigurationError.new(N_('Provider metadata is missing %s'), endpoint) if metadata[endpoint].blank?
        http_client.validate_url!(metadata[endpoint])
      end
      OPTIONAL_ENDPOINTS.each do |endpoint|
        http_client.validate_url!(metadata[endpoint]) if metadata[endpoint].present?
      end
      challenge_methods = metadata['code_challenge_methods_supported']
      if auth_source.oidc_use_pkce? && challenge_methods.present? && (!challenge_methods.is_a?(Array) || !challenge_methods.include?('S256'))
        raise Oidc::ConfigurationError, N_('The provider does not support the configured PKCE S256 method')
      end
      response_types = metadata['response_types_supported']
      if response_types.present? && (!response_types.is_a?(Array) || !response_types.include?('code'))
        raise Oidc::ConfigurationError, N_('The provider does not support the authorization code flow')
      end
      methods = metadata['token_endpoint_auth_methods_supported']
      if !auth_source.public_client? && methods.present? && (!methods.is_a?(Array) || !methods.include?(auth_source.oidc_client_auth_method))
        raise Oidc::ConfigurationError, N_('The provider does not support the configured client authentication method')
      end
      signing_algorithms = metadata['id_token_signing_alg_values_supported']
      if signing_algorithms.present? && (!signing_algorithms.is_a?(Array) || (auth_source.allowed_algorithms & signing_algorithms).empty?)
        raise Oidc::ConfigurationError, N_('The provider does not support any configured ID token signing algorithm')
      end

      metadata.slice('issuer', 'authorization_endpoint', 'token_endpoint', 'userinfo_endpoint',
        'jwks_uri', 'end_session_endpoint', 'code_challenge_methods_supported',
        'token_endpoint_auth_methods_supported', 'id_token_signing_alg_values_supported')
    end

    def secure_compare(left, right)
      left.is_a?(String) && right.is_a?(String) && left.present? && right.present? &&
        left.bytesize == right.bytesize && ActiveSupport::SecurityUtils.secure_compare(left, right)
    end
  end
end
