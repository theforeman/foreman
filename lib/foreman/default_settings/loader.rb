require 'rubygems'
require 'facter'
require 'puppet'

module Foreman
  module DefaultSettings
    module Loader
      class << self

        def set name, description, default, value = nil
          value ||= SETTINGS[name.to_sym]
          {:name => name, :value => value, :description => description, :default => default}
        end

        def create opts
          if (s=Setting.first(:conditions => {:name => (opts[:name])})).nil?
            Setting.create!(opts)
          else
            s.update_attribute(:default, opts[:default]) unless s.default == opts[:default]
          end
        end

        def load(reset=false)

          # We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
          Setting.first rescue return

          Setting.transaction do
            domain = Facter.domain
            [
              set('administrator', "The default administrator email address", "root@#{domain}"),
              set('foreman_url',   "The hostname where your Foreman instance is reachable", "foreman.#{domain}"),
              set('email_replay_address', "The email reply address for emails that Foreman is sending", "Foreman-noreply@#{domain}"),
              set('entries_per_page', "The amount of records shown per page in Foreman", 20),
              set('authorize_login_delegation',"Authorize login delegation with REMOTE_USER environment variable",false),
              set('idle_timeout',"Log out idle users after a certain number of minutes",60),
            ].each { |s| create s.update(:category => "General")}

            [
              set('root_pass',     "Default encrypted root password on provisioned hosts (default is 123123)", "xybxa6JUkz63w"),
              set('safemode_render', "Enable safe mode config templates rendering (recommended)", true),
              set('ssl_certificate', "SSL Certificate path that Foreman would use to communicate with its proxies", Puppet.settings[:hostcert]),
              set('ssl_ca_file',  "SSL CA file that Foreman will use to communicate with its proxies", Puppet.settings[:localcacert]),
              set('ssl_priv_key', "SSL Private Key file that Foreman will use to communicate with its proxies", Puppet.settings[:hostprivkey]),
              set('manage_puppetca', "Should Foreman automate certificate signing upon provisioning new host", true),
              set('ignore_puppet_facts_for_provisioning', "Does not update ipaddress and MAC values from Puppet facts", false),
              set('query_local_nameservers', "Should Foreman query the locally configured name server or the SOA/NS authorities", false)
            ].each { |s| create s.update(:category => "Provisioning")}

            [
              set('puppet_interval', "Puppet interval in minutes", 30 ),
              set('default_puppet_environment',"The Puppet environment Foreman will default to in case it can't auto detect it", "production"),
              set('modulepath',"The Puppet default module path in case Foreman can't auto detect it", "/etc/puppet/modules"),
              set('document_root', "Document root where puppetdoc files should be created", "#{Rails.root}/public/puppet/rdoc"),
              set('puppetrun', "Enables Puppetrun support", false),
              set('puppet_server', "Default Puppet server hostname", "puppet"),
              set('failed_report_email_notification', "Enable Email alerts per each failed Puppet report", false),
              set('using_storeconfigs', "Foreman is sharing its database with Puppet Store configs", (!Puppet.settings.instance_variable_get(:@values)[:master][:dbadapter].empty? rescue false)),
              set('Default_variables_Lookup_Path', "The Default path in which Foreman resolves host specific variables", ["fqdn", "hostgroup", "os", "domain"]),
              set('Enable_Smart_Variables_in_ENC', "Should the smart variables be exposed via the ENC yaml output?", true),
              set('enc_environment', "Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)", true),
              set('use_uuid_for_certificates', "Should Foreman use random UUID's for certificate signing instead of hostnames", false),
              set('update_environment_from_facts', "Should Foreman update a host's environment from its facts", false)
            ].compact.each { |s| create s.update(:category => "Puppet")}
          end
          true
        end
      end
    end
  end
end
