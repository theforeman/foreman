module Hostext
  module Search
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions
      include ConfigurationStatusScopedSearch
      include SmartProxyHostExtensions

      has_many :search_parameters, :class_name => 'Parameter', :foreign_key => :reference_id
      belongs_to :search_users, :class_name => 'User', :foreign_key => :owner_id
      belongs_to :usergroups, :class_name => 'Usergroup', :foreign_key => :owner_id

      scoped_search :on => :name,          :complete_value => true, :default_order => true
      scoped_search :on => :last_report,   :complete_value => true, :only_explicit => true
      scoped_search :on => :created_at,    :complete_value => true, :only_explicit => true
      scoped_search :on => :comment,       :complete_value => true
      scoped_search :on => :enabled,       :complete_value => {:true => true, :false => false}, :rename => :'status.enabled'
      scoped_search :on => :managed,       :complete_value => {:true => true, :false => false}
      scoped_search :on => :owner_type,    :complete_value => true, :only_explicit => true
      scoped_search :on => :owner_id,      :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :on => :id,            :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

      scoped_search :relation => :last_report_object, :on => :origin, :only_explicit => true

      scoped_search :relation => :configuration_status_object, :on => :status, :offset => 0, :word_size => ConfigReport::BIT_NUM * 4, :rename => :'status.interesting', :complete_value => {:true => true, :false => false}, :only_explicit => true
      scoped_search_status "applied",         :relation => :configuration_status_object, :on => :status, :rename => :'status.applied'
      scoped_search_status "restarted",       :relation => :configuration_status_object, :on => :status, :rename => :'status.restarted'
      scoped_search_status "failed",          :relation => :configuration_status_object, :on => :status, :rename => :'status.failed'
      scoped_search_status "failed_restarts", :relation => :configuration_status_object, :on => :status, :rename => :'status.failed_restarts'
      scoped_search_status "skipped",         :relation => :configuration_status_object, :on => :status, :rename => :'status.skipped'
      scoped_search_status "pending",         :relation => :configuration_status_object, :on => :status, :rename => :'status.pending'

      scoped_search :on => :global_status, :complete_value => { :ok => HostStatus::Global::OK, :warning => HostStatus::Global::WARN, :error => HostStatus::Global::ERROR }, :only_explicit => true

      scoped_search :relation => :model,       :on => :name,    :complete_value => true,  :rename => :model
      scoped_search :relation => :hostgroup,   :on => :name,    :complete_value => true,  :rename => :hostgroup
      scoped_search :relation => :hostgroup,   :on => :name,    :complete_enabled => false, :rename => :hostgroup_name, :only_explicit => true
      scoped_search :relation => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_fullname
      scoped_search :relation => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_title, :only_explicit => true
      scoped_search :relation => :hostgroup,   :on => :id,      :complete_enabled => false, :rename => :hostgroup_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :parent_hostgroup, :only_explicit => true, :ext_method => :search_by_hostgroup_and_descendants
      scoped_search :relation => :domain,      :on => :name,    :complete_value => true,  :rename => :domain
      scoped_search :relation => :domain,      :on => :id,      :complete_enabled => false, :rename => :domain_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :realm,       :on => :name,    :complete_value => true, :rename => :realm
      scoped_search :relation => :realm,       :on => :id,      :complete_enabled => false, :rename => :realm_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :architecture, :on => :name,    :complete_value => true, :rename => :architecture
      scoped_search :relation => :puppet_proxy, :on => :name,    :complete_value => true, :rename => :puppetmaster, :only_explicit => true
      scoped_search :on => :puppet_proxy_id, :complete_value => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :puppet_ca_proxy, :on => :name, :complete_value => true, :rename => :puppet_ca, :only_explicit => true
      scoped_search :relation => :puppet_proxy, :on => :name, :complete_value => true, :rename => :smart_proxy, :ext_method => :search_by_proxy, :only_explicit => true
      scoped_search :relation => :compute_resource, :on => :name,    :complete_value => true, :rename => :compute_resource
      scoped_search :relation => :compute_resource, :on => :id,      :complete_enabled => false, :rename => :compute_resource_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :image, :on => :name, :complete_value => true, :rename => :image

      scoped_search :relation => :operatingsystem, :on => :name,        :complete_value => true, :rename => :os
      scoped_search :relation => :operatingsystem, :on => :description, :complete_value => true, :rename => :os_description
      scoped_search :relation => :operatingsystem, :on => :title,       :complete_value => true, :rename => :os_title
      scoped_search :relation => :operatingsystem, :on => :major,       :complete_value => true, :rename => :os_major, :only_explicit => true, :ext_method => :search_by_os_major
      scoped_search :relation => :operatingsystem, :on => :minor,       :complete_value => true, :rename => :os_minor, :only_explicit => true, :ext_method => :search_by_os_minor
      scoped_search :relation => :operatingsystem, :on => :id,          :complete_enabled => false, :rename => :os_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

      scoped_search :relation => :primary_interface, :on => :ip, :complete_value => true
      scoped_search :relation => :interfaces, :on => :ip, :complete_value => true, :rename => :has_ip, :only_explicit => true
      scoped_search :relation => :interfaces, :on => :mac, :complete_value => true, :rename => :has_mac, :only_explicit => true

      scoped_search :relation => :fact_values, :on => :value, :in_key => :fact_names, :on_key => :name, :rename => :facts, :complete_value => true, :only_explicit => true, :ext_method => :search_cast_facts
      scoped_search :relation => :search_parameters, :on => :name, :complete_value => true, :rename => :params_name, :only_explicit => true
      scoped_search :relation => :search_parameters, :on => :searchable_value, :in_key => :search_parameters, :on_key => :name, :complete_value => true, :rename => :params, :ext_method => :search_by_params, :only_explicit => true, :operators => ['= ', '~ ']

      scoped_search :relation => :reported_data, :on => :boot_time, :rename => 'boot_time', :only_explicit => true

      scoped_search :relation => :location, :on => :title, :rename => :location, :complete_value => true, :only_explicit => true
      scoped_search :on => :location_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
      scoped_search :relation => :organization, :on => :title, :rename => :organization, :complete_value => true, :only_explicit => true
      scoped_search :on => :organization_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

      if SETTINGS[:unattended]
        scoped_search :relation => :subnet,          :on => :network,     :complete_value => false, :rename => :subnet
        scoped_search :relation => :subnet,          :on => :name,        :complete_value => false, :rename => 'subnet.name'
        scoped_search :relation => :subnet6,         :on => :network,     :complete_value => false, :rename => :subnet6
        scoped_search :relation => :subnet6,         :on => :name,        :complete_value => false, :rename => 'subnet6.name'
        scoped_search :on => :uuid,                                       :complete_value => true
        scoped_search :on => :build,                                      :complete_value => {:true => true, :false => false}
        scoped_search :on => :installed_at,                               :complete_value => true, :only_explicit => true

        scoped_search :relation => :provision_interface, :on => :mac, :complete_value => true
      end

      scoped_search :relation => :search_users, :on => :login,     :complete_value => true, :only_explicit => true, :rename => :'user.login', :operators => ['= ', '~ '], :ext_method => :search_by_user, :aliases => [:owner]
      scoped_search :relation => :search_users, :on => :firstname, :complete_value => true, :only_explicit => true, :rename => :'user.firstname', :operators => ['= ', '~ '], :ext_method => :search_by_user
      scoped_search :relation => :search_users, :on => :lastname,  :complete_value => true, :only_explicit => true, :rename => :'user.lastname', :operators => ['= ', '~ '], :ext_method => :search_by_user
      scoped_search :relation => :search_users, :on => :mail,      :complete_value => true, :only_explicit => true, :rename => :'user.mail',     :operators => ['= ', '~ '], :ext_method => :search_by_user
      scoped_search :relation => :usergroups,   :on => :name,      :complete_value => true, :only_explicit => true, :rename => :'usergroup.name', :aliases => [:usergroup]
    end

    module ClassMethods
      def search_by_user(key, operator, value)
        clean_key = key.sub(/^.*\./, '')
        if value == "current_user"
          value = User.current.id
          clean_key = "id"
        elsif key == "owner"
          clean_key = "login"
        end
        key_name = User.connection.quote_column_name(clean_key)
        condition = sanitize_sql_for_conditions(["#{key_name} #{operator} ?", value_to_sql(operator, value)])

        user_ids = User.where(condition).reorder(nil).pluck(:id)

        return { conditions: '1 = 0' } if user_ids.empty?

        usergroup_ids = CachedUsergroupMember.where(user_id: user_ids)
                                             .reorder(nil)
                                             .distinct
                                             .pluck(:usergroup_id)

        sql = <<-SQL
          hosts.owner_id IS NOT NULL
            AND
          (
            (
              hosts.owner_type = 'User'
                AND
              hosts.owner_id IN (?)
            )
              OR
            (
              hosts.owner_type = 'Usergroup'
                AND
              hosts.owner_id IN (?)
            )
          )
        SQL

        { conditions: sanitize_sql_array([sql, user_ids, usergroup_ids]) }
      end

      def search_by_hostgroup_and_descendants(key, operator, value)
        conditions = sanitize_sql_for_conditions(["hostgroups.title #{operator} ?", value_to_sql(operator, value)])
        # Only one hostgroup (first) is used to determined descendants. Future TODO - alert if result results more than one hostgroup
        hostgroup = Hostgroup.unscoped.with_taxonomy_scope.find_by(conditions)
        if hostgroup.present?
          hostgroup_ids = hostgroup.subtree_ids
          opts = "hosts.hostgroup_id IN (#{hostgroup_ids.join(',')})"
        else
          opts = "hosts.id < 0"
        end
        {:conditions => opts}
      end

      def search_by_params(key, operator, value)
        key_name = key.sub(/^.*\./, '')
        condition = sanitize_sql_for_conditions(["name = ? and searchable_value #{operator} ?", key_name, value_to_sql(operator, value)])
        p = Parameter.where(condition).reorder(:priority)
        return {:conditions => '1 = 0'} if p.blank?

        max = p.first.priority
        condition = sanitize_sql_for_conditions(["name = ? and NOT(searchable_value #{operator} ?) and priority > ?", key_name, value_to_sql(operator, value), max])
        n = Parameter.where(condition).reorder(:priority)

        conditions = param_conditions(p)
        negate = param_conditions(n)

        conditions += " AND " unless conditions.blank? || negate.blank?
        conditions += " NOT(#{negate})" if negate.present?
        {:joins => :primary_interface, :conditions => conditions}
      end

      def search_by_proxy(key, operator, value)
        proxy_cond = sanitize_sql_for_conditions(["smart_proxies.name #{operator} ?", value_to_sql(operator, value)])
        host_ids = Host::Managed.reorder('')
                                .authorized(:view_hosts, Host)
                                .eager_load(proxy_join_tables)
                                .joins("LEFT JOIN smart_proxies ON smart_proxies.id IN (#{proxy_column_list})")
                                .where(proxy_cond)
                                .distinct
                                .pluck('hosts.id')
                                .join(',')
        host_ids = '-1' if host_ids.empty?
        {:conditions => "hosts.id IN (#{host_ids})"}
      end

      def search_cast_facts(key, operator, value)
        in_query = FactValue.unscoped.joins(:fact_name).select(:host_id).
                    where("#{FactName.table_name}.name = ?", key.split('.', 2).last).
                    where(cast_facts(FactValue.table_name, key, operator, value)).to_sql
        {
          :conditions => "#{Host::Managed.table_name}.id in (#{in_query})",
        }
      end

      def search_by_os_major(key, operator, value)
        condition = sanitize_sql_for_conditions(["CAST(major AS DECIMAL) #{operator} ?", value_to_sql(operator, value.to_f)])
        operatingsystem_ids = Operatingsystem.select(:id).where(condition).pluck('operatingsystems.id').join(',')
        operatingsystem_ids = '-1' if operatingsystem_ids.empty?
        {:conditions => "hosts.operatingsystem_id IN (#{operatingsystem_ids})"}
      end

      def search_by_os_minor(key, operator, value)
        y, z = value.split(".")
        z ||= 0
        operatingsystem_ids = []
        Operatingsystem.where.not(minor: [nil, '']).find_each do |os|
          os_y, os_z = os.minor.split('.')
          os_z ||= 0
          operator_addition1 = (operator.length == 1) ? "=" : ""
          operator_addition2 = (operator == "=") ? "=" : ""
          if os_y.to_i.public_send(operator + operator_addition1, y.to_i)
            if os_y == y
              if os_z.to_i.public_send(operator + operator_addition2, z.to_i)
                operatingsystem_ids.append(os.id)
              end
            else
              operatingsystem_ids.append(os.id)
            end
          end
        end
        operatingsystem_ids = ['-1'] if operatingsystem_ids.empty?
        {:conditions => "hosts.operatingsystem_id IN (#{operatingsystem_ids.join(',')})"}
      end

      private

      def param_conditions(p)
        conditions = []
        p.each do |param|
          case param.class.to_s
            when 'CommonParameter'
              conditions << "1 = 1" # include all Global parameters
            when 'DomainParameter'
              conditions << "nics.domain_id = #{param.reference_id}"
            when 'OsParameter'
              conditions << "hosts.operatingsystem_id = #{param.reference_id}"
            when 'GroupParameter'
              conditions << "hosts.hostgroup_id IN (#{param.hostgroup.subtree_ids.join(', ')})"
            when 'HostParameter'
              conditions << "hosts.id = #{param.reference_id}"
            when 'SubnetParameter'
              conditions << "nics.subnet_id = #{param.reference_id} OR nics.subnet6_id = #{param.reference_id}"
          end
        end
        conditions.empty? ? "" : "( #{conditions.join(' OR ')} )"
      end
    end
  end
end
