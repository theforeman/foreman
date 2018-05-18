class Setting::Auth < Setting
  def self.default_settings
    [
      self.set('oauth_active', N_("Foreman will use OAuth for API authorization"), false, N_('OAuth active')),
      self.set('oauth_consumer_key', N_("OAuth consumer key"), '', N_('OAuth consumer key'), nil, {:encrypted => true}),
      self.set('oauth_consumer_secret', N_("OAuth consumer secret"), '', N_("OAuth consumer secret"), nil, {:encrypted => true}),
      self.set('oauth_map_users', N_("Foreman will map users by username in request-header. If this is set to false, OAuth requests will have admin rights."), true, N_('OAuth map users')),
      self.set('failed_login_attempts_limit', N_("Foreman will block user login after this number of failed login attempts for 5 minutes from offending IP address. Set to 0 to disable bruteforce protection"), 30, N_('Failed login attempts limit')),
      self.set('restrict_registered_smart_proxies', N_('Only known Smart Proxies may access features that use Smart Proxy authentication'), true, N_('Restrict registered smart proxies')),
      self.set('require_ssl_smart_proxies', N_('Client SSL certificates are used to identify Smart Proxies (:require_ssl should also be enabled)'), true, N_('Require SSL for smart proxies')),
      self.set('trusted_hosts', N_('Hosts that will be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), [], N_('Trusted hosts')),
      self.set('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), nil, N_('SSL certificate')),
      self.set('ssl_ca_file', N_("SSL CA file that Foreman will use to communicate with its proxies"), nil, N_('SSL CA file')),
      self.set('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), nil, N_('SSL private key')),
      self.set('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN', N_('SSL client DN env')),
      self.set('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY', N_('SSL client verify env')),
      self.set('ssl_client_cert_env', N_("Environment variable containing a client's SSL certificate"), 'SSL_CLIENT_CERT', N_('SSL client cert env')),
      self.set('websockets_ssl_key', N_("Private key file that Foreman will use to encrypt websockets "), nil, N_('Websockets SSL key')),
      self.set('websockets_ssl_cert', N_("Certificate that Foreman will use to encrypt websockets "), nil, N_('Websockets SSL certificate')),
      # websockets_encrypt depends on key/cert when true, so initialize it last
      self.set('websockets_encrypt', N_("VNC/SPICE websocket proxy console access encryption (websockets_ssl_key/cert setting required)"), !!SETTINGS[:require_ssl], N_('Websockets encryption')),
      self.set('login_delegation_logout_url', N_('Redirect your users to this url on logout (authorize_login_delegation should also be enabled)'), nil, N_('Login delegation logout URL')),
      self.set('authorize_login_delegation_auth_source_user_autocreate', N_('Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created (keep unset to prevent the autocreation)'), nil, N_('Authorize login delegation auth source user autocreate')),
      self.set('authorize_login_delegation', N_("Authorize login delegation with REMOTE_USER environment variable"), false, N_('Authorize login delegation')),
      self.set('authorize_login_delegation_api', N_("Authorize login delegation with REMOTE_USER environment variable for API calls too"), false, N_('Authorize login delegation API')),
      self.set('idle_timeout', N_("Log out idle users after a certain number of minutes"), 60, N_('Idle timeout')),
      self.set('bmc_credentials_accessible', N_("Permits access to BMC interface passwords through ENC YAML output and in templates"), true, N_('BMC credentials access'))
    ]
  end

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      default_settings.compact.each { |s| self.create! s.update(:category => "Setting::Auth")}
    end

    true
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
