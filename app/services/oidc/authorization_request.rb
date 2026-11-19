module Oidc
  class AuthorizationRequest
    STATE_TTL = 10.minutes

    attr_reader :session_data, :url

    def initialize(auth_source, redirect_uri)
      @auth_source = auth_source
      @redirect_uri = redirect_uri
      @metadata = auth_source.metadata
      build
    end

    private

    attr_reader :auth_source, :redirect_uri, :metadata

    def build
      state = SecureRandom.urlsafe_base64(32)
      nonce = SecureRandom.urlsafe_base64(32)
      verifier = SecureRandom.urlsafe_base64(64)
      parameters = {
        :client_id => auth_source.oidc_client_id,
        :redirect_uri => redirect_uri,
        :response_type => 'code',
        :scope => auth_source.scopes.join(' '),
        :state => state,
        :nonce => nonce,
      }
      if auth_source.oidc_use_pkce?
        parameters[:code_challenge] = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), :padding => false)
        parameters[:code_challenge_method] = 'S256'
      end

      @session_data = {
        'auth_source_id' => auth_source.id,
        'state' => state,
        'nonce' => nonce,
        'code_verifier' => auth_source.oidc_use_pkce? ? verifier : nil,
        'created_at' => Time.now.utc.to_i,
      }.compact
      @url = append_query(metadata.fetch('authorization_endpoint'), parameters)
    end

    def append_query(url, parameters)
      uri = URI.parse(url)
      reserved = parameters.keys.map(&:to_s)
      existing = URI.decode_www_form(uri.query.to_s).reject { |key, _value| reserved.include?(key) }
      uri.query = URI.encode_www_form(existing + parameters.to_a)
      uri.to_s
    end
  end
end
