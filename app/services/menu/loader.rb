# We require these files explicitly as the menu classes can't be reloaded
# to keep the singletons working.
require 'menu/node'
require 'menu/item'
require 'menu/divider'
require 'menu/toggle'
require 'menu/manager'

module Menu
  class Loader
    def self.load
      Manager.map :header_menu

      Manager.map :user_menu do |menu|
        menu.item :my_account,
                  :caption => N_('My account'),
                  :url_hash => {:controller => '/users', :action => 'edit', :id => Proc.new { User.current.id }}
        menu.divider
        menu.item :logout,
                  :caption => N_('Log out'),
                  :html => {:method => :post},
                  :url_hash => {:controller => '/users', :action => 'logout'}
      end

      Manager.map :admin_menu do |menu|
        menu.sub_menu :administer_menu,  :caption => N_('Administer') do
          menu.item :locations,          :caption => N_('Locations') if SETTINGS[:locations_enabled]
          menu.item :organizations,      :caption => N_('Organizations') if SETTINGS[:organizations_enabled]
          menu.divider
          if SETTINGS[:login]
            menu.item :auth_source_ldaps,:caption => N_('LDAP authentication')
            menu.item :users,            :caption => N_('Users')
            menu.item :usergroups,       :caption => N_('User groups')
            menu.item :roles,            :caption => N_('Roles')
          end
          menu.divider
          menu.item :bookmarks,          :caption => N_('Bookmarks')
          menu.item :settings,           :caption => N_('Settings')
          menu.item :about_index,        :caption => N_('About')
        end
      end

      Manager.map :top_menu do |menu|
        menu.sub_menu :monitor_menu,    :caption => N_('Monitor') do
          menu.item :dashboard,         :caption => N_('Dashboard')
          menu.item :fact_values,       :caption => N_('Facts')
          menu.item :statistics,        :caption => N_('Statistics')
          menu.item :trends,            :caption => N_('Trends')
          menu.item :audits,            :caption => N_('Audits')
          menu.divider                  :caption => N_('Reports')
          menu.item :reports,           :caption => N_('Config management'),
                    :url_hash => {:controller => '/config_reports', :action => 'index', :search => 'eventful = true'}
          menu.divider
        end

        menu.sub_menu :hosts_menu,      :caption => N_('Hosts') do
          menu.item :hosts,             :caption => N_('All hosts')
          menu.item :newhost,           :caption => N_('New host'),
                    :url_hash => {:controller => '/hosts', :action => 'new'}
          if SETTINGS[:unattended]
            menu.divider                :caption => N_('Provisioning Setup')
            menu.item :architectures,   :caption => N_('Architectures')
            menu.item :models,          :caption => N_('Hardware models')
            menu.item :media,           :caption => N_('Installation media')
            menu.item :operatingsystems,:caption => N_('Operating systems')
            menu.divider                :caption => N_('Templates')
            menu.item :partition_tables, :caption => N_('Partition tables'),
                      :url_hash => { :controller => 'ptables', :action => 'index' }
            menu.item :provisioning_templates, :caption => N_('Provisioning templates'),
                      :url_hash => { :controller => 'provisioning_templates', :action => 'index' }
          end
        end

        menu.sub_menu :configure_menu,  :caption => N_('Configure') do
          menu.item :hostgroups,        :caption => N_('Host groups')
          menu.item :common_parameters, :caption => N_('Global parameters')
          menu.divider                  :caption => N_('Puppet')
          menu.item :environments,      :caption => N_('Environments')
          menu.item :puppetclasses,     :caption => N_('Classes')
          menu.item :config_groups,     :caption => N_('Config groups')
          menu.item :variable_lookup_keys, :caption => N_('Smart variables')
          menu.item :puppetclass_lookup_keys, :caption => N_('Smart class parameters')
        end

        menu.sub_menu :infrastructure_menu, :caption => N_('Infrastructure') do
          menu.item :smart_proxies,       :caption => N_('Smart proxies')
          if SETTINGS[:unattended]
            menu.item :compute_resources, :caption => N_('Compute resources')
            menu.item :compute_profiles,  :caption => N_('Compute profiles')
            menu.item :subnets,           :caption => N_('Subnets')
            menu.item :domains,           :caption => N_('Domains')
            menu.item :realms,            :caption => N_('Realms')
          end
        end
      end
    end
  end
end
