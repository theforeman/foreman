require_dependency 'menu/node'
require_dependency 'menu/item'
require_dependency 'menu/divider'
require_dependency 'menu/toggle'
require_dependency 'menu/manager'

module Menu
  class Loader
    def self.load
      Manager.map :header_menu

      if SETTINGS[:login]
        Manager.map :side_menu do |menu|
          menu.sub_menu :user_menu, :caption => N_('User'), :icon => 'fa fa-user' do
            menu.item :my_account,
                      :caption => N_('My Account'),
                      :url_hash => {:controller => '/users', :action => 'edit', :id => Proc.new { User.current.id }}
            menu.divider
            menu.item :logout,
                      :caption => N_('Log Out'),
                      :html => {:method => :post},
                      :url_hash => {:controller => '/users', :action => 'logout'}
          end
        end
      end

      Manager.map :admin_menu do |menu|
        menu.sub_menu :administer_menu,  :caption => N_('Administer'), :icon => 'fa fa-cog' do
          menu.item :locations,          :caption => N_('Locations') if SETTINGS[:locations_enabled]
          menu.item :organizations,      :caption => N_('Organizations') if SETTINGS[:organizations_enabled]
          if SETTINGS[:login]
            menu.item :auth_source_ldaps, :caption => N_('LDAP Authentication')
            menu.item :users,            :caption => N_('Users')
            menu.item :usergroups,       :caption => N_('User Groups')
            menu.item :roles,            :caption => N_('Roles')
          end
          menu.item :bookmarks,          :caption => N_('Bookmarks')
          menu.item :settings,           :caption => N_('Settings')
          menu.item :about_index,        :caption => N_('About')
        end
      end

      Manager.map :top_menu do |menu|
        menu.sub_menu :monitor_menu,    :caption => N_('Monitor'), :icon => 'fa fa-tachometer' do
          menu.item :dashboard,         :caption => N_('Dashboard')
          menu.item :fact_values,       :caption => N_('Facts')
          menu.item :statistics,        :caption => N_('Statistics')
          menu.item :trends,            :caption => N_('Trends')
          menu.item :audits,            :caption => N_('Audits')
          menu.divider                  :caption => N_('Reports')
          menu.item :reports,           :caption => N_('Config Management'),
                    :url_hash => {:controller => '/config_reports', :action => 'index', :search => 'eventful = true'}
          menu.divider
        end

        menu.sub_menu :hosts_menu,      :caption => N_('Hosts'), :icon => 'fa fa-server' do
          menu.item :hosts,             :caption => N_('All Hosts')
          menu.item :newhost,           :caption => N_('Create Host'),
                    :url_hash => {:controller => '/hosts', :action => 'new'}
          if SETTINGS[:unattended]
            menu.divider                :caption => N_('Provisioning Setup')
            menu.item :architectures,   :caption => N_('Architectures')
            menu.item :models,          :caption => N_('Hardware Models')
            menu.item :media,           :caption => N_('Installation Media')
            menu.item :operatingsystems, :caption => N_('Operating Systems')
            menu.divider :caption => N_('Templates')
            menu.item :partition_tables, :caption => N_('Partition Tables'),
                      :url_hash => { :controller => 'ptables', :action => 'index' }
            menu.item :provisioning_templates, :caption => N_('Provisioning Templates'),
                      :url_hash => { :controller => 'provisioning_templates', :action => 'index' }
          end
        end

        menu.sub_menu :configure_menu,  :caption => N_('Configure'), :icon => 'fa fa-wrench' do
          menu.item :hostgroups,        :caption => N_('Host Groups')
          menu.item :common_parameters, :caption => N_('Global Parameters')
          menu.divider                  :caption => N_('Puppet')
          menu.item :environments,      :caption => N_('Environments')
          menu.item :puppetclasses,     :caption => N_('Classes')
          menu.item :config_groups,     :caption => N_('Config Groups')
          menu.item :variable_lookup_keys, :caption => N_('Smart Variables')
          menu.item :puppetclass_lookup_keys, :caption => N_('Smart Class Parameters')
        end

        menu.sub_menu :infrastructure_menu, :caption => N_('Infrastructure'), :icon => 'pficon pficon-network' do
          menu.item :smart_proxies, :caption => N_('Smart Proxies')
          if SETTINGS[:unattended]
            menu.item :compute_resources, :caption => N_('Compute Resources')
            menu.item :compute_profiles,  :caption => N_('Compute Profiles')
            menu.item :subnets,           :caption => N_('Subnets')
            menu.item :domains,           :caption => N_('Domains')
            menu.item :http_proxies,      :caption => N_('HTTP Proxies')
            menu.item :realms,            :caption => N_('Realms')
          end
        end
      end

      Manager.map :labs_menu do |menu|
        menu.sub_menu :lab_features_menu, :caption => N_('Lab Features'), :icon => 'fa fa-flask'
      end
    end
  end
end
