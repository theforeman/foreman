require 'rubygems'
require 'facter'
require 'puppet_setting'

module Foreman
  module DefaultSettings
    module Loader
      class << self

        def set name, description, default, value = nil
          value ||= SETTINGS[name.to_sym]
          {:name => name, :value => value, :description => description, :default => default}
        end

        def create opts
          # ensures we don't have cache left overs in settings
          Rails.logger.debug "removing #{opts[:name]} from cache"
          Rails.cache.delete(opts[:name].to_s)

          if (s=Setting.first(:conditions => {:name => (opts[:name])})).nil?
            Setting.create!(opts)
          else
            s.update_attribute(:default, opts[:default]) unless s.default == opts[:default]
          end
        end

        def load(reset=false)
          ppsettings = PuppetSetting.new.get :hostcert, :localcacert, :hostprivkey, :storeconfigs

          # We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
          Setting.first rescue return

          Setting.transaction do
            domain = Facter.domain
            fqdn = Facter.fqdn
            [
              set('administrator', N_("The default administrator email address"), "root@#{domain}"),
              set('foreman_url',   N_("The hostname where your Foreman instance is reachable"), "foreman.#{domain}"),
              set('email_reply_address', N_("The email reply address for emails that Foreman is sending"), "Foreman-noreply@#{domain}"),
              set('entries_per_page', N_("The amount of records shown per page in Foreman"), 20),
              set('authorize_login_delegation',N_("Authorize login delegation with REMOTE_USER environment variable"),false),
              set('authorize_login_delegation_api',N_("Authorize login delegation with REMOTE_USER environment variable for API calls too"),false),
              set('idle_timeout',N_("Log out idle users after a certain number of minutes"),60),
              set('max_trend',N_("Max days for Trends graphs"),30),
              set('use_gravatar',N_("Should Foreman use gravatar to display user icons"),true)
            ].each { |s| create s.update(:category => N_("General"))}

            [
              set('root_pass',     N_("Default encrypted root password on provisioned hosts (default is 123123)"), "xybxa6JUkz63w"),
              set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true),
              set('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), ppsettings[:hostcert]),
              set('ssl_ca_file',  N_("SSL CA file that Foreman will use to communicate with its proxies"), ppsettings[:localcacert]),
              set('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), ppsettings[:hostprivkey]),
              set('manage_puppetca', N_("Should Foreman automate certificate signing upon provisioning new host"), true),
              set('ignore_puppet_facts_for_provisioning', N_("Does not update ipaddress and MAC values from Puppet facts"), false),
              set('query_local_nameservers', N_("Should Foreman query the locally configured name server or the SOA/NS authorities"), false),
              set('remote_addr', N_("If Foreman is running behind Passenger or a remote loadbalancer, the ip should be set here"), "127.0.0"),
              set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable"), 0)
            ].each { |s| create s.update(:category => N_("Provisioning"))}

            param_enc = Gem::Version.new(Facter.puppetversion.split('-').first) >= Gem::Version.new('2.6.5')
            [
              set('puppet_interval', N_("Puppet interval in minutes"), 30 ),
              set('default_puppet_environment',N_("The Puppet environment Foreman will default to in case it can't auto detect it"), "production"),
              set('modulepath',N_("The Puppet default module path in case Foreman can't auto detect it"), "/etc/puppet/modules"),
              set('document_root', N_("Document root where puppetdoc files should be created"), "#{Rails.root}/public/puppet/rdoc"),
              set('puppetrun', N_("Enables Puppetrun support"), false),
              set('puppet_server', N_("Default Puppet server hostname"), "puppet"),
              set('failed_report_email_notification', N_("Enable Email alerts per each failed Puppet report"), false),
              set('using_storeconfigs', N_("Foreman is sharing its database with Puppet Store configs"), ppsettings[:storeconfigs] == 'true'),
              set('Default_variables_Lookup_Path', N_("The Default path in which Foreman resolves host specific variables"), ["fqdn", "hostgroup", "os", "domain"]),
              set('Enable_Smart_Variables_in_ENC', N_("Should the smart variables be exposed via the ENC yaml output?"), true),
              set('Parametrized_Classes_in_ENC', N_("Should Foreman use the new format (2.6.5+) to answer Puppet in its ENC yaml output?"), param_enc),
              set('enc_environment', N_("Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)"), true),
              set('use_uuid_for_certificates', N_("Should Foreman use random UUID's for certificate signing instead of hostnames"), false),
              set('update_environment_from_facts', N_("Should Foreman update a host's environment from its facts"), false),
              set('remove_classes_not_in_environment',
                  N_("When Host and Hostgroup have different environments should all classes be included (regardless if they exists or not in the other environment)"), false)
            ].compact.each { |s| create s.update(:category => N_("Puppet"))}

            [ set('oauth_active', N_("Should foreman use OAuth for authorization in API"), false),
              set('oauth_consumer_key', N_("OAuth consumer key"), 'katello'),
              set('oauth_consumer_secret', N_("OAuth consumer secret"), 'shhhh'),
              set('oauth_map_users', N_("Should foreman map users by username in request-header"), true),
              set('restrict_registered_puppetmasters', N_('Only known Smart Proxies with the Puppet feature can access fact/report importers and ENC output'), true),
              set('require_ssl_puppetmasters', N_('Client SSL certificates are used to identify Smart Proxies accessing fact/report importers and ENC output over HTTPS (:require_ssl should also be enabled)'), true),
              set('trusted_puppetmaster_hosts', N_('Hosts that will be trusted in addition to Smart Proxies for access to fact/report importers and ENC output'), []),
              set('ssl_client_dn_env', N_('Environment variable containing the subject DN from a client SSL certificate'), 'SSL_CLIENT_S_DN'),
              set('ssl_client_verify_env', N_('Environment variable containing the verification status of a client SSL certificate'), 'SSL_CLIENT_VERIFY'),
              set('signo_sso', N_('Use Signo SSO for login'), false),
              set('signo_url', N_('Signo SSO url'), "https://#{fqdn}/signo")
            ].compact.each { |s| create s.update(:category => "Auth")}
          end
          true
        end
      end
    end
  end
end
