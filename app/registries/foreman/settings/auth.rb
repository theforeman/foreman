Foreman::SettingManager.define(:foreman) do
  category(:auth, N_('Authentication')) do
    setting('oauth_active',
      type: :boolean,
      description: N_("Foreman will use OAuth for API authorization"),
      default: false,
      full_name: N_('OAuth active'))
    setting('oauth_consumer_key',
      type: :string,
      description: N_("OAuth consumer key"),
      default: '',
      full_name: N_('OAuth consumer key'),
      encrypted: true)
    setting('oauth_consumer_secret',
      type: :string,
      description: N_("OAuth consumer secret"),
      default: '',
      full_name: N_("OAuth consumer secret"),
      encrypted: true)
    setting('oauth_map_users',
      type: :boolean,
      description: N_("When enabled, Foreman will map users by username in request-header. If this is disabled, OAuth requests will have admin rights."),
      default: true,
      full_name: N_('OAuth map users'))
    setting('failed_login_attempts_limit',
      type: :integer,
      description: N_("Foreman will block user logins from an IP address after this number of failed login attempts for 5 minutes. Set to 0 to disable bruteforce protection"),
      default: 30,
      full_name: N_('Failed login attempts limit'))
    setting('restrict_registered_smart_proxies',
      type: :boolean,
      description: N_('Only known Smart Proxies may access features that use Smart Proxy authentication'),
      default: true,
      full_name: N_('Restrict registered smart proxies'))
    setting('trusted_hosts',
      type: :array,
      description: N_('List of hostnames, IPv4, IPv6 addresses or subnets to be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'),
      default: [],
      full_name: N_('Trusted hosts'))
    setting('ssl_certificate',
      type: :string,
      description: N_("SSL Certificate path that Foreman would use to communicate with its proxies"),
      default: nil,
      full_name: N_('SSL certificate'))
    setting('ssl_ca_file',
      type: :string,
      description: N_("SSL CA file path that Foreman will use to communicate with its proxies"),
      default: nil,
      full_name: N_('SSL CA file'))
    setting('ssl_priv_key',
      type: :string,
      description: N_("SSL Private Key path that Foreman will use to communicate with its proxies"),
      default: nil,
      full_name: N_('SSL private key'))
    setting('ssl_client_dn_env',
      type: :string,
      description: N_('Environment variable containing the subject DN from a client SSL certificate'),
      default: 'SSL_CLIENT_S_DN',
      full_name: N_('SSL client DN env'))
    setting('ssl_client_verify_env',
      type: :string,
      description: N_('Environment variable containing the verification status of a client SSL certificate'),
      default: 'SSL_CLIENT_VERIFY',
      full_name: N_('SSL client verify env'))
    setting('ssl_client_cert_env',
      type: :string,
      description: N_("Environment variable containing a client's SSL certificate"),
      default: 'SSL_CLIENT_CERT',
      full_name: N_('SSL client cert env'))
    setting('server_ca_file',
      type: :string,
      description: N_("SSL CA file path that will be used in templates (to verify the connection to Foreman)"),
      default: nil,
      full_name: N_('Server CA file'))

    setting('websockets_ssl_key',
      type: :string,
      description: N_("Private key file path that Foreman will use to encrypt websockets"),
      default: nil,
      full_name: N_('Websockets SSL key'))
    setting('websockets_ssl_cert',
      type: :string,
      description: N_("Certificate path that Foreman will use to encrypt websockets"),
      default: nil,
      full_name: N_('Websockets SSL certificate'))
    # websockets_encrypt depends on key/cert when true, so initialize it last
    setting('websockets_encrypt',
      type: :boolean,
      description: N_("VNC/SPICE websocket proxy console access encryption (websockets_ssl_key/cert setting required)"),
      default: !!SETTINGS[:require_ssl],
      full_name: N_('Websockets encryption'))
    validates('websockets_encrypt', ->(value) { !value || !(Setting["websockets_ssl_key"].empty? || Setting["websockets_ssl_cert"].empty?) }, message: N_("Unable to turn on websockets_encrypt, either websockets_ssl_key or websockets_ssl_cert is missing"))
    validates('websockets_ssl_key', ->(value) { !Setting["websockets_encrypt"] || !value.empty? }, message: N_("Unable to unset websockets_ssl_key when websockets_encrypt is on"))
    validates('websockets_ssl_cert', ->(value) { !Setting["websockets_encrypt"] || !value.empty? }, message: N_("Unable to unset websockets_ssl_cert when websockets_encrypt is on"))

    setting('login_delegation_logout_url',
      type: :string,
      description: N_('Redirect your users to this url on logout (authorize_login_delegation should also be enabled)'),
      default: nil,
      full_name: N_('Login delegation logout URL'))
    setting('authorize_login_delegation_auth_source_user_autocreate',
      type: :string,
      description: N_('Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created. Empty means no autocreation.'),
      default: 'External',
      full_name: N_('Authorize login delegation auth source user autocreate'))
    setting('authorize_login_delegation',
      type: :boolean,
      description: N_("Authorize login delegation with REMOTE_USER HTTP header"),
      default: false,
      full_name: N_('Authorize login delegation'))
    setting('authorize_login_delegation_api',
      type: :boolean,
      description: N_("Authorize login delegation with REMOTE_USER HTTP header for API calls too"),
      default: false,
      full_name: N_('Authorize login delegation API'))
    setting('idle_timeout',
      type: :integer,
      description: N_("Log out idle users after a certain number of minutes"),
      default: 60,
      full_name: N_('Idle timeout'))
    setting('bcrypt_cost',
      type: :integer,
      description: N_("Cost value of bcrypt password hash function for internal auth-sources (4-30). A higher value is safer but verification is slower, particularly for stateless API calls and UI logins. A password change is needed effect existing passwords."),
      default: 4,
      full_name: N_('BCrypt password cost'))
    setting('bmc_credentials_accessible',
      type: :boolean,
      description: N_("Permits access to BMC interface passwords through ENC YAML output and in templates"),
      default: false,
      full_name: N_('BMC credentials access'))
    setting('oidc_jwks_url',
      type: :string,
      description: N_("OpenID Connect JSON Web Key Set(JWKS) URL. Typically https://keycloak.example.com/auth/realms/<realm name>/protocol/openid-connect/certs when using Keycloak as an OpenID provider"),
      default: nil,
      full_name: N_('OIDC JWKs URL'))
    setting('oidc_audience',
      type: :array,
      description: N_("Name of the OpenID Connect Audience that is being used for Authentication. In case of Keycloak this is the Client ID."),
      default: [],
      full_name: N_('OIDC Audience'))
    setting('oidc_issuer',
      type: :string,
      description: N_("The iss (issuer) claim identifies the principal that issued the JWT, which exists at a `/.well-known/openid-configuration` in case of most of the OpenID providers."),
      default: nil,
      full_name: N_('OIDC Issuer'))
    setting('oidc_algorithm',
      type: :string,
      description: N_("The algorithm used to encode the JWT in the OpenID provider."),
      default: nil,
      full_name: N_('OIDC Algorithm'))
  end
end
