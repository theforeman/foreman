require 'facter'
class Setting::Auth < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    fqdn = Facter.fqdn
    self.transaction do
        Setting::Auth.init_on_startup!('oauth_active', N_("Should foreman use OAuth for authorization in API"), false)
        Setting::Auth.init_on_startup!('oauth_consumer_key', N_("OAuth consumer key"), 'katello')
        Setting::Auth.init_on_startup!('oauth_consumer_secret', N_("OAuth consumer secret"), 'shhhh')
        Setting::Auth.init_on_startup!('oauth_map_users', N_("Should foreman map users by username in request-header"), true)
        Setting::Auth.init_on_startup!('restrict_registered_puppetmasters', N_('Only known Smart Proxies with the Puppet feature can access fact/report importers and ENC output'), true)
        Setting::Auth.init_on_startup!('require_ssl_puppetmasters', N_('Client SSL certificates are used to identify Smart Proxies accessing fact/report importers and ENC output over HTTPS (:require_ssl should also be enabled)'), true)
        Setting::Auth.init_on_startup!('trusted_puppetmaster_hosts', N_('Hosts that will be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), [])
        Setting::Auth.init_on_startup!('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN')
        Setting::Auth.init_on_startup!('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY')
        Setting::Auth.init_on_startup!('signo_sso', N_('Use Signo SSO for login'), false)
        Setting::Auth.init_on_startup!('signo_url', N_('Signo SSO url'), "https://#{fqdn}/signo")
    end
    true
  end

end
