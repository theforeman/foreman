module AuditSearch
  extend ActiveSupport::Concern

  included do
    belongs_to :user, :class_name => 'User'
    belongs_to :search_users, :class_name => 'User', :foreign_key => :user_id
    belongs_to :search_hosts, -> { where(:audits => { :auditable_type => 'Host::Base' }) },
      :class_name => 'Host::Base', :foreign_key => :auditable_id
    belongs_to :search_hostgroups, :class_name => 'Hostgroup', :foreign_key => :auditable_id
    belongs_to :search_parameters, :class_name => 'Parameter', :foreign_key => :auditable_id
    belongs_to :search_templates, :class_name => 'ProvisioningTemplate', :foreign_key => :auditable_id
    belongs_to :search_ptables, :class_name => 'Ptable', :foreign_key => :auditable_id
    belongs_to :search_os, :class_name => 'Operatingsystem', :foreign_key => :auditable_id
    belongs_to :search_class, :class_name => 'Puppetclass', :foreign_key => :auditable_id
    belongs_to :search_nics, -> { where('audits.auditable_type LIKE ?', "Nic::%") }, :class_name => 'Nic::Base', :foreign_key => :auditable_id
    belongs_to :search_settings, :class_name => 'Setting', :foreign_key => :auditable_id

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :request_uuid, :complete_value => false, :only_explicit => true
    scoped_search :on => [:username, :remote_address, :comment], :complete_value => true
    scoped_search :on => :audited_changes, :rename => 'changes'
    scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
    scoped_search :on => :action, :complete_value => true
    scoped_search :on => :auditable_type, :complete_value => auditable_type_complete_values, :rename => :type
    scoped_search :on => :auditable_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    scoped_search :relation => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
    scoped_search :relation => :search_templates, :on => :name, :complete_value => true, :rename => :provisioning_template, :only_explicit => true
    scoped_search :relation => :search_ptables, :on => :name, :complete_value => true, :rename => :partition_table, :only_explicit => true
    scoped_search :relation => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
    scoped_search :relation => :search_os, :on => :title, :complete_value => true, :rename => :os_title, :only_explicit => true
    scoped_search :relation => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
    scoped_search :relation => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
    scoped_search :relation => :search_hostgroups, :on => :title, :complete_value => true, :rename => :hostgroup_title, :only_explicit => true
    scoped_search :relation => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true,
      :special_values => %w[current_user], :value_translation => ->(value) { value == 'current_user' ? User.current.login : value }
    scoped_search :relation => :search_nics, :on => :name, :complete_value => true, :rename => :interface_fqdn, :only_explicit => true
    scoped_search :relation => :search_nics, :on => :ip, :complete_value => true, :rename => :interface_ip, :only_explicit => true
    scoped_search :relation => :search_nics, :on => :mac, :complete_value => true, :rename => :interface_mac, :only_explicit => true
    scoped_search :relation => :search_settings, :on => :name, :complete_value => true, :rename => :setting, :only_explicit => true
    scoped_search :on => :user_id,
      :complete_value => true,
      :rename => 'user.id',
      :validator => ->(value) { ScopedSearch::Validators::INTEGER.call(value) },
      :value_translation => ->(value) { value == 'current_user' ? User.current.id : value },
      :special_values => %w[current_user],
      :only_explicit => true

    def user_login
      user.login rescue nil
    end
  end

  module ClassMethods
    def auditable_type_complete_values
      # Note: this will only work properly in production, as models are lazy loaded
      # in development, meaning we won't have all the class names when this runs.
      complete_values = audited_classes_without_sti.each_with_object({}) do |name, obj|
        obj[name.underscore.to_sym] = name
      end
      # Add aliases and STI handling
      complete_values.merge!(
        :auth_source => 'AuthSource',
        :compute_resource => 'ComputeResource',
        :host => 'Host::Base',
        :interface => 'Nic::Base',
        :location => 'Location',
        :organization => 'Organization',
        :os => 'Operatingsystem',
        :override_value => 'LookupValue',
        :parameter => 'Parameter',
        :partition_table => 'Ptable',
        :setting => 'Setting',
        :smart_class_parameter => 'PuppetclassLookupKey',
        :subnet => 'Subnet',
        :provisioning_template => 'ProvisioningTemplate'
      )
    end

    def find_complete_keytype_array(auditable_type)
      auditable_type_complete_values.find { |key, type_name| type_name == auditable_type }
    end

    private

    # This is a workaround needed until we get proper STI auditing
    def audited_classes_without_sti
      audited_class_names.reject do |name|
        klass = name.constantize
        klass != klass.base_class ||
        klass.descendants.any?
      end
    end
  end
end
