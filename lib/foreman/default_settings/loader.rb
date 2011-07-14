module Foreman
  module DefaultSettings
    module Loader
      class << self

        def set name, description, default, value = nil
          value ||= SETTINGS[name.to_sym]
          {:name => name, :value => value, :description => description, :default => default}
        end

        def create opts
          if ((s=Setting.first(:conditions => {:name => (opts[:name])})).nil?)
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
              set('administrator', "The Default administrator email address", "root@#{domain}"),
              set('foreman_url',   "The hostname where your foreman instance is running on", "foreman.#{domain}"),
            ].each { |s| create s.update(:category => "General")}

            [
              set('root_pass',     "Default ecrypted root password on provisioned hosts default is 123123", "xybxa6JUkz63w"),
              set('safemode_render', "Enable safe mode config templates rendinging(recommended)", true),
              set('ssl_certificate', "SSL Certificate path that foreman would use to communicate with its proxies", Puppet.settings[:hostcert]),
              set('ssl_ca_file',  "SSL CA file that foreman would use to communicate with its proxies", Puppet.settings[:localcacert]),
              set('ssl_priv_key', "SSL Private Key file that foreman would use to communicate with its proxies", Puppet.settings[:hostprivkey]),
              set('manage_puppetca', "Should foreman automate certificate signing upon provisioning new host", true),
              set('ignore_puppet_facts_for_provisioning', "Does not update ipaddress and MAC values from puppet facts", false)
            ].each { |s| create s.update(:category => "Provisioning")}

            [
              set('puppet_interval', "Puppet interval in minutes", 30 ),
              set('default_puppet_environment',"The Puppet environment foreman would default to in case it can't auto detect it", "production"),
              set('modulepath',"The Puppet default module path in case that Foreman can't auto detect it", "/etc/puppet/modules"),
              set('document_root', "Document root where puppetdoc files should be created", "#{RAILS_ROOT}/public/puppet/rdoc"),
              set('puppetrun', "Enables Puppetrun Support", false),
              set('puppet_server', "Default Puppet Server hostname", "puppet"),
              set('failed_report_email_notification', "Enable Email Alerts per each failed puppet report", false),
              set('using_storeconfigs', "Foreman is sharing its database with Puppet Store configs", (!Puppet.settings.instance_variable_get(:@values)[:master][:dbadapter].empty? rescue false)),
              set('Default_variables_Lookup_Path', "The Default path in which foreman resolves host specific variables", ["fqdn", "hostgroup", "os", "domain"]),
              set('Enable_Smart_Variables_in_ENC', "Should the smart variables be exposed via the ENC yaml output?", true)
            ].compact.each { |s| create s.update(:category => "Puppet")}


          end
          true
        end
      end
    end
  end
end
