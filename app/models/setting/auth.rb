require 'facter'
class Setting::Auth < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      [
        self.set('oauth_active', N_("Foreman will use OAuth for API authorization"), false),
        self.set('oauth_consumer_key', N_("OAuth consumer key"), ''),
        self.set('oauth_consumer_secret', N_("OAuth consumer secret"), ''),
        self.set('oauth_map_users', N_("Foreman will map users by username in request-header. If this is set to false, OAuth requests will have admin rights."), true),
        self.set('restrict_registered_smart_proxies', N_('Only known Smart Proxies may access features that use Smart Proxy authentication'), true),
        self.set('require_ssl_smart_proxies', N_('Client SSL certificates are used to identify Smart Proxies (:require_ssl should also be enabled)'), true),
        self.set('trusted_puppetmaster_hosts', N_('Hosts that will be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), []),
        self.set('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN'),
        self.set('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY'),
        self.set('login_delegation_logout_url', N_('Redirect your users to this url on logout (authorize_login_delegation should also be enabled)'), nil),
        self.set('authorize_login_delegation_auth_source_user_autocreate', N_('Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created (keep unset to prevent the autocreation)'), nil),
      ].compact.each { |s| self.create! s.update(:category => "Setting::Auth")}
    end

    true

  end

end
