module Oidc
  class LogoutURL
    def initialize(auth_source, redirect_uri)
      @auth_source = auth_source
      @redirect_uri = redirect_uri
    end

    def to_s
      endpoint = auth_source.metadata['end_session_endpoint']
      return if endpoint.blank?

      uri = URI.parse(endpoint)
      parameters = {
        :client_id => auth_source.oidc_client_id,
        :post_logout_redirect_uri => redirect_uri,
      }
      reserved = parameters.keys.map(&:to_s)
      existing = URI.decode_www_form(uri.query.to_s).reject { |key, _value| reserved.include?(key) }
      uri.query = URI.encode_www_form(existing + parameters.to_a)
      uri.to_s
    rescue Oidc::Error, URI::InvalidURIError => exception
      Foreman::Logging.exception('Unable to build the OpenID Connect logout URL', exception)
      nil
    end

    private

    attr_reader :auth_source, :redirect_uri
  end
end
