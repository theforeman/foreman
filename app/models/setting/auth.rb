class Setting::Auth < Setting
  def self.default_settings
    [
      set('oauth_active', N_("Foreman will use OAuth for API authorization"), false, N_('OAuth active')),
      set('oauth_consumer_key', N_("OAuth consumer key"), '', N_('OAuth consumer key'), nil, {:encrypted => true}),
      set('oauth_consumer_secret', N_("OAuth consumer secret"), '', N_("OAuth consumer secret"), nil, {:encrypted => true}),
      set('oauth_map_users', N_("Foreman will map users by username in request-header. If this is set to false, OAuth requests will have admin rights."), true, N_('OAuth map users')),
      set('failed_login_attempts_limit', N_("Foreman will block user login after this number of failed login attempts for 5 minutes from offending IP address. Set to 0 to disable bruteforce protection"), 30, N_('Failed login attempts limit')),
      set('restrict_registered_smart_proxies', N_('Only known Smart Proxies may access features that use Smart Proxy authentication'), true, N_('Restrict registered smart proxies')),
      set('require_ssl_smart_proxies', N_('Client SSL certificates are used to identify Smart Proxies (:require_ssl should also be enabled)'), true, N_('Require SSL for smart proxies')),
      set('trusted_hosts', N_('List of hostnames, IPv4, IPv6 addresses or subnets to be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), [], N_('Trusted hosts')),
      set('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), nil, N_('SSL certificate')),
      set('ssl_ca_file', N_("SSL CA file that Foreman will use to communicate with its proxies"), nil, N_('SSL CA file')),
      set('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), nil, N_('SSL private key')),
      set('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN', N_('SSL client DN env')),
      set('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY', N_('SSL client verify env')),
      set('ssl_client_cert_env', N_("Environment variable containing a client's SSL certificate"), 'SSL_CLIENT_CERT', N_('SSL client cert env')),
      set('server_ca_file', N_("SSL CA file that will be used in templates (to verify the connection to Foreman)"), nil, N_('Server CA file')),
      set('websockets_ssl_key', N_("Private key file that Foreman will use to encrypt websockets "), nil, N_('Websockets SSL key')),
      set('websockets_ssl_cert', N_("Certificate that Foreman will use to encrypt websockets "), nil, N_('Websockets SSL certificate')),
      # websockets_encrypt depends on key/cert when true, so initialize it last
      set('websockets_encrypt', N_("VNC/SPICE websocket proxy console access encryption (websockets_ssl_key/cert setting required)"), !!SETTINGS[:require_ssl], N_('Websockets encryption')),
      set('login_delegation_logout_url', N_('Redirect your users to this url on logout (authorize_login_delegation should also be enabled)'), nil, N_('Login delegation logout URL')),
      set('authorize_login_delegation_auth_source_user_autocreate', N_('Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created (If you want to prevent the autocreation, keep unset)'), 'External', N_('Authorize login delegation auth source user autocreate')),
      set('authorize_login_delegation', N_("Authorize login delegation with REMOTE_USER HTTP header"), false, N_('Authorize login delegation')),
      set('authorize_login_delegation_api', N_("Authorize login delegation with REMOTE_USER HTTP header for API calls too"), false, N_('Authorize login delegation API')),
      set('idle_timeout', N_("Log out idle users after a certain number of minutes"), 60, N_('Idle timeout')),
      set('bcrypt_cost', N_("Cost value of bcrypt password hash function for internal auth-sources (4-30). Higher value is safer but verification is slower particularly for stateless API calls and UI logins. Password change needed to take effect."), 4, N_('BCrypt password cost')),
      set('bmc_credentials_accessible', N_("Permits access to BMC interface passwords through ENC YAML output and in templates"), true, N_('BMC credentials access')),
      set('oidc_jwks_url', N_("OpenID Connect JSON Web Key Set(JWKS) URL. Typically https://keycloak.example.com/auth/realms/<realm name>/protocol/openid-connect/certs when using Keycloak as an OpenID provider"), nil, N_('OIDC JWKs URL')),
      set('oidc_audience', N_("Name of the OpenID Connect Audience that is being used for Authentication. In case of Keycloak this is the Client ID."), [], N_('OIDC Audience')),
      set('oidc_issuer', N_("The iss (issuer) claim identifies the principal that issued the JWT, which exists at a `/.well-known/openid-configuration` in case of most of the OpenID providers."), nil, N_('OIDC Issuer')),
      set('oidc_algorithm', N_("The algorithm used to encode the JWT in the OpenID provider."), nil, N_('OIDC Algorithm')),
    ]
  end

  def self.humanized_category
    N_('Authentication')
  end

  def validate_bmc_credentials_accessible(record)
    if !record.value && !Setting[:safemode_render]
      record.errors[:base] << _("Unable to disable bmc_credentials_accessible when safemode_render is disabled")
    end
  end

  def validate_websockets_encrypt(record)
    if record.value && (Setting["websockets_ssl_key"].empty? || Setting["websockets_ssl_cert"].empty?)
      record.errors[:base] << _("Unable to turn on websockets_encrypt, either websockets_ssl_key or websockets_ssl_cert is missing")
    end
  end

  def validate_websockets_ssl_key(record)
    if record.value.empty? && Setting["websockets_encrypt"]
      record.errors[:base] << _("Unable to unset websockets_ssl_key when websockets_encrypt is on")
    end
  end

  def validate_websockets_ssl_cert(record)
    if record.value.empty? && Setting["websockets_encrypt"]
      record.errors[:base] << _("Unable to unset websockets_ssl_cert when websockets_encrypt is on")
    end
  end
end
