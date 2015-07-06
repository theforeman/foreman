module Hostext
  module Search
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions
      include ConfigurationStatusScopedSearch

      has_many :search_parameters, :class_name => 'Parameter', :foreign_key => :reference_id
      belongs_to :search_users, :class_name => 'User', :foreign_key => :owner_id

      scoped_search :on => :name,          :complete_value => true, :default_order => true
      scoped_search :on => :last_report,   :complete_value => true, :only_explicit => true
      scoped_search :on => :comment,       :complete_value => true
      scoped_search :on => :enabled,       :complete_value => {:true => true, :false => false}, :rename => :'status.enabled'
      scoped_search :on => :managed,       :complete_value => {:true => true, :false => false}
      scoped_search :on => :owner_type,    :complete_value => true, :only_explicit => true
      scoped_search :on => :owner_id,      :complete_enabled => false, :only_explicit => true

      scoped_search :in => :configuration_status_object, :on => :status, :offset => 0, :word_size => ConfigReport::BIT_NUM*4, :rename => :'status.interesting', :complete_value => {:true => true, :false => false}
      scoped_search_status "applied",         :in => :configuration_status_object, :on => :status, :rename => :'status.applied'
      scoped_search_status "restarted",       :in => :configuration_status_object, :on => :status, :rename => :'status.restarted'
      scoped_search_status "failed",          :in => :configuration_status_object, :on => :status, :rename => :'status.failed'
      scoped_search_status "failed_restarts", :in => :configuration_status_object, :on => :status, :rename => :'status.failed_restarts'
      scoped_search_status "skipped",         :in => :configuration_status_object, :on => :status, :rename => :'status.skipped'
      scoped_search_status "pending",         :in => :configuration_status_object, :on => :status, :rename => :'status.pending'

      scoped_search :on => :global_status, :complete_value => { :ok => HostStatus::Global::OK, :warning => HostStatus::Global::WARN, :error => HostStatus::Global::ERROR }

      scoped_search :in => :model,       :on => :name,    :complete_value => true,  :rename => :model
      scoped_search :in => :hostgroup,   :on => :name,    :complete_value => true,  :rename => :hostgroup
      scoped_search :in => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_fullname
      scoped_search :in => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_title
      scoped_search :in => :hostgroup,   :on => :id,      :complete_enabled => false, :rename => :hostgroup_id, :only_explicit => true
      scoped_search :in => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :parent_hostgroup, :only_explicit => true, :ext_method => :search_by_hostgroup_and_descendants
      scoped_search :in => :domain,      :on => :name,    :complete_value => true,  :rename => :domain
      scoped_search :in => :domain,      :on => :id,      :complete_enabled => false,  :rename => :domain_id, :only_explicit => true
      scoped_search :in => :realm,       :on => :name,    :complete_value => true,  :rename => :realm
      scoped_search :in => :realm,       :on => :id,      :complete_enabled => false,  :rename => :realm_id, :only_explicit => true
      scoped_search :in => :environment, :on => :name,    :complete_value => true,  :rename => :environment
      scoped_search :in => :architecture, :on => :name,    :complete_value => true, :rename => :architecture
      scoped_search :in => :puppet_proxy, :on => :name,    :complete_value => true, :rename => :puppetmaster
      scoped_search :in => :puppet_ca_proxy, :on => :name,    :complete_value => true, :rename => :puppet_ca
      scoped_search :in => :compute_resource, :on => :name,    :complete_value => true, :rename => :compute_resource
      scoped_search :in => :compute_resource, :on => :id,      :complete_enabled => false, :rename => :compute_resource_id, :only_explicit => true
      scoped_search :in => :image, :on => :name, :complete_value => true

      scoped_search :in => :operatingsystem, :on => :name,        :complete_value => true, :rename => :os
      scoped_search :in => :operatingsystem, :on => :description, :complete_value => true, :rename => :os_description
      scoped_search :in => :operatingsystem, :on => :title,       :complete_value => true, :rename => :os_title
      scoped_search :in => :operatingsystem, :on => :major,       :complete_value => true, :rename => :os_major
      scoped_search :in => :operatingsystem, :on => :minor,       :complete_value => true, :rename => :os_minor
      scoped_search :in => :operatingsystem, :on => :id,          :complete_enabled => false,:rename => :os_id, :only_explicit => true

      scoped_search :in => :primary_interface, :on => :ip, :complete_value => true
      scoped_search :in => :interfaces, :on => :ip, :complete_value => true, :rename => :has_ip
      scoped_search :in => :interfaces, :on => :mac, :complete_value => true, :rename => :has_mac

      scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_puppetclass
      scoped_search :in => :fact_values, :on => :value, :in_key=> :fact_names, :on_key=> :name, :rename => :facts, :complete_value => true, :only_explicit => true, :ext_method => :search_cast_facts
      scoped_search :in => :search_parameters, :on => :value, :on_key=> :name, :complete_value => true, :rename => :params, :ext_method => :search_by_params, :only_explicit => true

      if SETTINGS[:locations_enabled]
        scoped_search :in => :location, :on => :title, :rename => :location, :complete_value => true
        scoped_search :on => :location_id, :complete_enabled => false, :only_explicit => true
      end
      if SETTINGS[:organizations_enabled]
        scoped_search :in => :organization, :on => :title, :rename => :organization, :complete_value => true
        scoped_search :on => :organization_id, :complete_enabled => false, :only_explicit => true
      end
      scoped_search :in => :config_groups, :on => :name, :complete_value => true, :rename => :config_group, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_config_group

      if SETTINGS[:unattended]
        scoped_search :in => :subnet,          :on => :network,     :complete_value => true, :rename => :subnet
        scoped_search :in => :subnet,          :on => :name,        :complete_value => true, :rename => 'subnet.name'
        scoped_search :on => :uuid,                                 :complete_value => true
        scoped_search :on => :build,                                :complete_value => {:true => true, :false => false}
        scoped_search :on => :installed_at,                         :complete_value => true, :only_explicit => true

        scoped_search :in => :provision_interface, :on => :mac,       :complete_value => true
        scoped_search :in => :operatingsystem, :on => :name,        :complete_value => true, :rename => :os
        scoped_search :in => :operatingsystem, :on => :description, :complete_value => true, :rename => :os_description
        scoped_search :in => :operatingsystem, :on => :title,       :complete_value => true, :rename => :os_title
        scoped_search :in => :operatingsystem, :on => :major,       :complete_value => true, :rename => :os_major
        scoped_search :in => :operatingsystem, :on => :minor,       :complete_value => true, :rename => :os_minor
        scoped_search :in => :operatingsystem, :on => :id,          :complete_value => false,:rename => :os_id, :complete_enabled => false
      end

      if SETTINGS[:login]
        scoped_search :in => :search_users, :on => :login,     :complete_value => true, :only_explicit => true, :rename => :'user.login',    :operators => ['= ', '~ '], :ext_method => :search_by_user, :alias => :owner
        scoped_search :in => :search_users, :on => :firstname, :complete_value => true, :only_explicit => true, :rename => :'user.firstname',:operators => ['= ', '~ '], :ext_method => :search_by_user
        scoped_search :in => :search_users, :on => :lastname,  :complete_value => true, :only_explicit => true, :rename => :'user.lastname', :operators => ['= ', '~ '], :ext_method => :search_by_user
        scoped_search :in => :search_users, :on => :mail,      :complete_value => true, :only_explicit => true, :rename => :'user.mail',     :operators => ['= ', '~ '], :ext_method => :search_by_user
      end
    end

    module ClassMethods
      def search_by_user(key, operator, value)
        clean_key = key.sub(/^.*\./,'')
        if value == "current_user"
          value = User.current.id
          clean_key = "id"
        elsif key == "owner"
          clean_key = "login"
        end
        key_name = User.connection.quote_column_name(clean_key)
        condition = sanitize_sql_for_conditions(["#{key_name} #{operator} ?", value_to_sql(operator, value)])
        users = User.all(:conditions => condition)
        hosts = users.map(&:hosts).flatten
        opts  = hosts.empty? ? "< 0" : "IN (#{hosts.map(&:id).join(',')})"

        {:conditions => " hosts.id #{opts} " }
      end

      def search_by_puppetclass(key, operator, value)
        conditions    = sanitize_sql_for_conditions(["puppetclasses.name #{operator} ?", value_to_sql(operator, value)])
        config_group_ids = ConfigGroup.where(conditions).joins(:puppetclasses).pluck('config_groups.id')
        host_ids         = Host.authorized(:view_hosts, Host).where(conditions).joins(:puppetclasses).uniq.pluck('hosts.id')
        host_ids        += HostConfigGroup.where(:host_type => 'Host::Base').where(:config_group_id => config_group_ids).pluck(:host_id)
        hostgroups       = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).joins(:puppetclasses)
        hostgroups      += Hostgroup.unscoped.with_taxonomy_scope.joins(:host_config_groups).where("host_config_groups.config_group_id IN (#{config_group_ids.join(',')})") if config_group_ids.any?
        hostgroup_ids    = hostgroups.map(&:subtree_ids).flatten.uniq

        opts  = ''
        opts += "hosts.id IN(#{host_ids.join(',')})"            unless host_ids.blank?
        opts += " OR "                                          unless host_ids.blank? || hostgroup_ids.blank?
        opts += "hostgroups.id IN(#{hostgroup_ids.join(',')})"  unless hostgroup_ids.blank?
        opts  = "hosts.id < 0"                                  if host_ids.blank? && hostgroup_ids.blank?
        {:conditions => opts, :include => :hostgroup}
      end

      def search_by_hostgroup_and_descendants(key, operator, value)
        conditions     = sanitize_sql_for_conditions(["hostgroups.title #{operator} ?", value_to_sql(operator, value)])
        # Only one hostgroup (first) is used to determined descendants. Future TODO - alert if result results more than one hostgroup
        hostgroup     = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).first
        hostgroup_ids = hostgroup.subtree_ids
        if hostgroup_ids.any?
          opts = "hosts.hostgroup_id IN (#{hostgroup_ids.join(',')})"
        else
          opts = "hosts.id < 0"
        end
        {:conditions => opts}
      end

      def search_by_params(key, operator, value)
        key_name = key.sub(/^.*\./,'')
        condition = sanitize_sql_for_conditions(["name = ? and value #{operator} ?", key_name, value_to_sql(operator, value)])
        opts     = {:conditions => condition, :order => :priority}
        p        = Parameter.all(opts)
        return {:conditions => '1 = 0'} if p.blank?

        max         = p.first.priority
        condition   = sanitize_sql_for_conditions(["name = ? and NOT(value #{operator} ?) and priority > ?",key_name,value_to_sql(operator, value), max])
        negate_opts = {:conditions => condition, :order => :priority}
        n           = Parameter.all(negate_opts)

        conditions = param_conditions(p)
        negate = param_conditions(n)

        conditions += " AND " unless conditions.blank? || negate.blank?
        conditions += " NOT(#{negate})" unless negate.blank?
        {:conditions => conditions}
      end

      def search_by_config_group(key, operator, value)
        conditions  = sanitize_sql_for_conditions(["config_groups.name #{operator} ?", value_to_sql(operator, value)])
        host_ids      = Host::Managed.authorized(:view_hosts, Host).where(conditions).joins(:config_groups).uniq.pluck('hosts.id')
        hostgroup_ids = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).joins(:config_groups).uniq.map(&:subtree_ids).flatten.uniq

        opts = ''
        opts += "hosts.id IN(#{host_ids.join(',')})"             unless host_ids.blank?
        opts += " OR "                                        unless host_ids.blank? || hostgroup_ids.blank?
        opts += "hostgroups.id IN(#{hostgroup_ids.join(',')})"  unless hostgroup_ids.blank?
        opts = "hosts.id < 0"                                 if host_ids.blank? && hostgroup_ids.blank?
        {:conditions => opts, :include => :hostgroup}
      end

      def search_cast_facts(key, operator, value)
        {
          :conditions => "fact_names.name = '#{key.split('.')[1]}' AND #{cast_facts(key,operator,value)}",
          :include    => :fact_names,
        }
      end

      private

      def param_conditions(p)
        conditions = []
        p.each do |param|
          case param.class.to_s
            when 'CommonParameter'
              # ignore
            when 'DomainParameter'
              conditions << "hosts.domain_id = #{param.reference_id}"
            when 'OsParameter'
              conditions << "hosts.operatingsystem_id = #{param.reference_id}"
            when 'GroupParameter'
              conditions << "hosts.hostgroup_id IN (#{param.hostgroup.subtree_ids.join(', ')})"
            when 'HostParameter'
              conditions << "hosts.id = #{param.reference_id}"
          end
        end
        conditions.empty? ? [] : "( #{conditions.join(' OR ')} )"
      end
    end
  end
end
