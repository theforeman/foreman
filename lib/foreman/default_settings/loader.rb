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
            [
              set('administrator', "The default administrator email address", "root@#{domain}"),
              set('foreman_url',   "The hostname where your Foreman instance is reachable", "foreman.#{domain}"),
              set('email_reply_address', "The email reply address for emails that Foreman is sending", "Foreman-noreply@#{domain}"),
              set('entries_per_page', "The amount of records shown per page in Foreman", 20),
              set('authorize_login_delegation',"Authorize login delegation with REMOTE_USER environment variable",false),
              set('authorize_login_delegation_api',"Authorize login delegation with REMOTE_USER environment variable for API calls too",false),
              set('idle_timeout',"Log out idle users after a certain number of minutes",60),
              set('max_trend',"Max days for Trends graphs",30)
            ].each { |s| create s.update(:category => "General")}

            [
              set('root_pass',     "Default encrypted root password on provisioned hosts (default is 123123)", "xybxa6JUkz63w"),
              set('safemode_render', "Enable safe mode config templates rendering (recommended)", true),
              set('ssl_certificate', "SSL Certificate path that Foreman would use to communicate with its proxies", ppsettings[:hostcert]),
              set('ssl_ca_file',  "SSL CA file that Foreman will use to communicate with its proxies", ppsettings[:localcacert]),
              set('ssl_priv_key', "SSL Private Key file that Foreman will use to communicate with its proxies", ppsettings[:hostprivkey]),
              set('manage_puppetca', "Should Foreman automate certificate signing upon provisioning new host", true),
              set('ignore_puppet_facts_for_provisioning', "Does not update ipaddress and MAC values from Puppet facts", false),
              set('query_local_nameservers', "Should Foreman query the locally configured name server or the SOA/NS authorities", false),
              set('remote_addr', "If Foreman is running behind Passenger or a remote loadbalancer, the ip should be set here", "127.0.0"),
              set('token_duration', "Time in minutes installation tokens should be valid for, 0 to disable", 0)
            ].each { |s| create s.update(:category => "Provisioning")}

            param_enc = Gem::Version.new(Facter.puppetversion.split('-').first) >= Gem::Version.new('2.6.5')
            [
              set('puppet_interval', "Puppet interval in minutes", 30 ),
              set('default_puppet_environment',"The Puppet environment Foreman will default to in case it can't auto detect it", "production"),
              set('modulepath',"The Puppet default module path in case Foreman can't auto detect it", "/etc/puppet/modules"),
              set('document_root', "Document root where puppetdoc files should be created", "#{Rails.root}/public/puppet/rdoc"),
              set('puppetrun', "Enables Puppetrun support", false),
              set('puppet_server', "Default Puppet server hostname", "puppet"),
              set('failed_report_email_notification', "Enable Email alerts per each failed Puppet report", false),
              set('using_storeconfigs', "Foreman is sharing its database with Puppet Store configs", ppsettings[:storeconfigs] == 'true'),
              set('Default_variables_Lookup_Path', "The Default path in which Foreman resolves host specific variables", ["fqdn", "hostgroup", "os", "domain"]),
              set('Enable_Smart_Variables_in_ENC', "Should the smart variables be exposed via the ENC yaml output?", true),
              set('Parametrized_Classes_in_ENC', "Should Foreman use the new format (2.6.5+) to answer Puppet in its ENC yaml output?", param_enc),
              set('enc_environment', "Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)", true),
              set('use_uuid_for_certificates', "Should Foreman use random UUID's for certificate signing instead of hostnames", false),
              set('update_environment_from_facts', "Should Foreman update a host's environment from its facts", false),
              set('remove_classes_not_in_environment',
                  "When Host and Hostgroup have different environments should all classes be included (regardless if they exists or not in the other environment)", false)
            ].compact.each { |s| create s.update(:category => "Puppet")}

            [ set('oauth_active', "Should foreman use OAuth for authorization in API", false),
              set('oauth_consumer_key', "OAuth consumer key", 'katello'),
              set('oauth_consumer_secret', "OAuth consumer secret", 'shhhh'),
              set('oauth_map_users', "Should foreman map users by username in request-header", true),
              set('restrict_registered_puppetmasters', 'Only known Smart Proxies with the Puppet feature can access fact/report importers and ENC output', true),
              set('require_ssl_puppetmasters', 'Client SSL certificates are used to identify Smart Proxies accessing fact/report importers and ENC output over HTTPS (:require_ssl should also be enabled)', true),
              set('ssl_client_dn_env', 'Environment variable containing the subject DN from a client SSL certificate', 'SSL_CLIENT_S_DN'),
              set('ssl_client_verify_env', 'Environment variable containing the verification status of a client SSL certificate', 'SSL_CLIENT_VERIFY')
            ].compact.each { |s| create s.update(:category => "Auth")}
          end
          true
        end
      end
    end
  end
end
