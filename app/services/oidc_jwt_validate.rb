class OidcJwtValidate
  attr_reader :decoded_token
  delegate :logger, to: :Rails

  def initialize(jwt_token)
    @jwt_token = jwt_token
  end

  def decoded_payload
    # OpenSSL#set_key method does not support ruby version < 2.4.0, apparently the JWT gem uses
    # OpenSSL#set_key method for all ruby version. We must remove this condition once new version
    # of the JWT(2.2.2) is released.
    unless OpenSSL::PKey::RSA.new.respond_to?(:set_key)
      Foreman::Logging.logger('app').error "SSO feature is not available for Ruby < 2.4.0"
      return nil
    end
    JWT.decode(@jwt_token, nil, true,
      { aud: Setting['oidc_audience'],
        verify_aud: true,
        iss: Setting['oidc_issuer'],
        verify_iss: true,
        algorithms: [Setting['oidc_algorithm']],
        jwks: jwks_loader }
    ).first
  rescue JWT::DecodeError => e
    Foreman::Logging.exception('Failed to decode JWT', e)
    nil
  end

  private

  def jwks_loader(options = {})
    response = RestClient::Request.execute(
      :url => Setting['oidc_jwks_url'],
      :method => :get,
      :verify_ssl => true
    )
    json_response = JSON.parse(response)
    if json_response.is_a?(Hash)
      jwks_keys = json_response['keys']
      { keys: jwks_keys.map(&:symbolize_keys) }
    else
      Foreman::Logging.logger('app').error "Invalid JWKS response."
      {}
    end
  rescue RestClient::Exception, SocketError, JSON::ParserError => e
    Foreman::Logging.exception('Failed to load the JWKS', e)
    {}
  end
end
