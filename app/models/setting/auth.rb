require 'facter'
class Setting::Auth < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    fqdn = Facter.fqdn || Facter.hostname
    self.transaction do
      [
        self.set('oauth_active', N_("Should foreman use OAuth for authorization in API"), false),
        self.set('oauth_consumer_key', N_("OAuth consumer key"), 'katello'),
        self.set('oauth_consumer_secret', N_("OAuth consumer secret"), 'shhhh'),
        self.set('oauth_map_users', N_("Should foreman map users by username in request-header"), true),
        self.set('restrict_registered_puppetmasters', N_('Only known Smart Proxies with the Puppet feature can access fact/report importers and ENC output'), true),
        self.set('require_ssl_puppetmasters', N_('Client SSL certificates are used to identify Smart Proxies accessing fact/report importers and ENC output over HTTPS (:require_ssl should also be enabled)'), true),
        self.set('trusted_puppetmaster_hosts', N_('Hosts that will be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), []),
        self.set('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN'),
        self.set('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY'),
        self.set('signo_sso', N_('Use Signo SSO for login'), false),
        self.set('signo_url', N_('Signo SSO url'), "https://#{fqdn}/signo")
      ].compact.each { |s| self.create! s.update(:category => "Setting::Auth")}
    end

    true

  end

end
