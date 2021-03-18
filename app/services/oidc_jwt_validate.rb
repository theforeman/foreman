class OidcJwtValidate
  attr_reader :decoded_token
  delegate :logger, to: :Rails

  def initialize(jwt_token)
    @jwt_token = jwt_token
  end

  def decoded_payload
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
