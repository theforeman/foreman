module Oidc
  class Authenticator
    Result = Struct.new(:claims, :subject, :email, :email_verified, :groups, :keyword_init => true)

    def initialize(auth_source, redirect_uri)
      @auth_source = auth_source
      @redirect_uri = redirect_uri
      @metadata = auth_source.metadata
      @http_client = Oidc::HttpClient.new(auth_source)
    end

    def authenticate(code, nonce, code_verifier = nil)
      token_response = exchange_code(code, code_verifier)
      validate_token_type(token_response)
      id_claims = Oidc::TokenVerifier.new(auth_source).verify(
        token_response.fetch('id_token'), nonce, token_response['access_token']
      )
      claims = id_claims.merge(userinfo(token_response, id_claims['sub']))
      reader = Oidc::ClaimReader.new(claims)
      groups = reader.read(auth_source.oidc_groups_claim)
      groups = case groups
               when Array then groups
               when String then [groups]
               else []
               end
      email = reader.read(auth_source.oidc_email_claim)
      email = nil unless email.is_a?(String)

      Result.new(
        :claims => claims,
        :subject => id_claims['sub'],
        :email => email,
        :email_verified => claims['email_verified'] == true,
        :groups => groups.select { |group| group.is_a?(String) && group.bytesize <= 255 }.first(1000)
      )
    rescue KeyError => exception
      raise Oidc::AuthenticationError.new(N_('The token response is missing %s'), exception.key)
    end

    private

    attr_reader :auth_source, :redirect_uri, :metadata, :http_client

    def exchange_code(code, code_verifier)
      payload = {
        :grant_type => 'authorization_code',
        :code => code,
        :redirect_uri => redirect_uri,
      }
      payload[:code_verifier] = code_verifier if code_verifier.present?
      headers = { :content_type => 'application/x-www-form-urlencoded' }

      case auth_source.oidc_client_auth_method
      when 'client_secret_basic'
        credentials = [auth_source.oidc_client_id, auth_source.oidc_client_secret].map do |value|
          URI.encode_www_form_component(value.to_s)
        end.join(':')
        headers[:authorization] = "Basic #{Base64.strict_encode64(credentials)}"
      when 'client_secret_post'
        payload[:client_id] = auth_source.oidc_client_id
        payload[:client_secret] = auth_source.oidc_client_secret
      when 'none'
        payload[:client_id] = auth_source.oidc_client_id
      end

      http_client.post_form(metadata.fetch('token_endpoint'), payload, headers)
    end

    def validate_token_type(token_response)
      return if token_response['access_token'].blank?
      return if token_response['token_type'].to_s.casecmp('Bearer').zero?

      raise Oidc::AuthenticationError, N_('The token response contains an unsupported token type')
    end

    def userinfo(token_response, subject)
      endpoint = metadata['userinfo_endpoint']
      access_token = token_response['access_token']
      return {} if endpoint.blank? || access_token.blank?

      claims = http_client.get_json(endpoint, :authorization => "Bearer #{access_token}")
      unless secure_compare(claims['sub'], subject)
        raise Oidc::AuthenticationError, N_('The UserInfo subject does not match the ID token')
      end
      claims.except('iss', 'aud', 'azp', 'exp', 'iat', 'nbf', 'nonce')
    end

    def secure_compare(left, right)
      left.is_a?(String) && right.is_a?(String) && left.present? && right.present? &&
        left.bytesize == right.bytesize && ActiveSupport::SecurityUtils.secure_compare(left, right)
    end
  end
end
