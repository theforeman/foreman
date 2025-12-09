# OmniAuth configuration for native OIDC support
# This initializer configures OmniAuth providers based on AuthSourceOidc records

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.path_prefix = '/users/auth'
    config.logger = Rails.logger if Rails.env.development?
    config.allowed_request_methods = [:post, :get]
  end

  begin
    if ActiveRecord::Base.connection.table_exists?('auth_sources')
      AuthSourceOidc.all.each do |auth_source|
        Rails.logger.debug "OIDC: Configuring provider '#{auth_source.name}' (#{auth_source.provider_name}) for issuer #{auth_source.oidc_issuer}"

        issuer_uri = URI.parse(auth_source.oidc_issuer)
        use_discovery = !auth_source.uses_manual_endpoints?
        redirect_uri = auth_source.oidc_redirect_uri

        if redirect_uri.blank?
          Rails.logger.warn "OIDC: Provider '#{auth_source.name}' has no redirect_uri configured. " \
                           "Ensure foreman_url setting is configured and restart Foreman."
          next
        end

        provider_options = {
          name: auth_source.provider_name,
          issuer: auth_source.oidc_issuer,
          discovery: use_discovery,
          scope: auth_source.scopes_array,
          response_type: :code,
          uid_field: 'sub',
          client_options: {
            identifier: auth_source.oidc_client_id,
            secret: auth_source.oidc_client_secret,
            redirect_uri: redirect_uri,
            scheme: issuer_uri.scheme,
            host: issuer_uri.host,
            port: issuer_uri.port,
          },
        }

        unless use_discovery
          provider_options.merge!(
            authorization_endpoint: auth_source.oidc_authorization_endpoint,
            token_endpoint: auth_source.oidc_token_endpoint,
            userinfo_endpoint: auth_source.oidc_userinfo_endpoint,
            jwks_uri: auth_source.oidc_jwks_uri,
            end_session_endpoint: auth_source.oidc_end_session_endpoint
          )
        end

        provider :openid_connect, provider_options

        mode = use_discovery ? 'discovery' : 'manual endpoints'
        Rails.logger.debug "OIDC: Provider '#{auth_source.name}' configured (#{mode}, host: #{issuer_uri.host})"
      end

      provider_count = AuthSourceOidc.count
      if provider_count == 0
        Rails.logger.debug "OIDC: No OIDC providers configured"
      else
        Rails.logger.debug "OIDC: Configured #{provider_count} OIDC provider(s)"
      end
    else
      Rails.logger.debug "OIDC: auth_sources table does not exist yet"
    end
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
    Foreman::Logging.exception("OIDC: Database not available, skipping provider configuration", e, :level => :warn)
  rescue => e
    Foreman::Logging.exception("OIDC: Failed to configure providers", e, :level => :error)
  end
end

OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OmniAuth.config.logger = Rails.logger
OmniAuth.config.silence_get_warning = true if Rails.env.development?
