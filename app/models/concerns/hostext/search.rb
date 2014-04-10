module Hostext
  module Search
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions

      has_many :search_parameters, :class_name => 'Parameter', :foreign_key => :reference_id
      belongs_to :search_users, :class_name => 'User', :foreign_key => :owner_id

      scoped_search :on => :name,          :complete_value => true, :default_order => true
      scoped_search :on => :last_report,   :complete_value => true, :only_explicit => true
      scoped_search :on => :ip,            :complete_value => true
      scoped_search :on => :comment,       :complete_value => true
      scoped_search :on => :enabled,       :complete_value => {:true => true, :false => false}, :rename => :'status.enabled'
      scoped_search :on => :managed,       :complete_value => {:true => true, :false => false}
      scoped_search :on => :owner_type,    :complete_value => true, :only_explicit => true
      scoped_search :on => :owner_id,      :complete_value => true, :only_explicit => true
      scoped_search :on => :puppet_status, :offset => 0, :word_size => Report::BIT_NUM*4, :complete_value => {:true => true, :false => false}, :rename => :'status.interesting'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("applied"),         :word_size => Report::BIT_NUM, :rename => :'status.applied'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("restarted"),       :word_size => Report::BIT_NUM, :rename => :'status.restarted'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("failed"),          :word_size => Report::BIT_NUM, :rename => :'status.failed'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("failed_restarts"), :word_size => Report::BIT_NUM, :rename => :'status.failed_restarts'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("skipped"),         :word_size => Report::BIT_NUM, :rename => :'status.skipped'
      scoped_search :on => :puppet_status, :offset => Report::METRIC.index("pending"),         :word_size => Report::BIT_NUM, :rename => :'status.pending'

      scoped_search :in => :model,       :on => :name,    :complete_value => true,  :rename => :model
      scoped_search :in => :hostgroup,   :on => :name,    :complete_value => true,  :rename => :hostgroup
      scoped_search :in => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_fullname
      scoped_search :in => :hostgroup,   :on => :title,   :complete_value => true,  :rename => :hostgroup_title
      scoped_search :in => :hostgroup,   :on => :id,      :complete_value => false, :rename => :hostgroup_id, :only_explicit => true
      scoped_search :in => :domain,      :on => :name,    :complete_value => true,  :rename => :domain
      scoped_search :in => :domain,      :on => :id,      :complete_value => true,  :rename => :domain_id
      scoped_search :in => :realm,       :on => :name,    :complete_value => true,  :rename => :realm
      scoped_search :in => :realm,       :on => :id,      :complete_value => true,  :rename => :realm_id
      scoped_search :in => :environment, :on => :name,    :complete_value => true,  :rename => :environment
      scoped_search :in => :architecture, :on => :name,    :complete_value => true, :rename => :architecture
      scoped_search :in => :puppet_proxy, :on => :name,    :complete_value => true, :rename => :puppetmaster
      scoped_search :in => :puppet_ca_proxy, :on => :name,    :complete_value => true, :rename => :puppet_ca
      scoped_search :in => :compute_resource, :on => :name,    :complete_value => true, :rename => :compute_resource
      scoped_search :in => :image, :on => :name, :complete_value => true

      scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_puppetclass
      scoped_search :in => :fact_values, :on => :value, :in_key=> :fact_names, :on_key=> :name, :rename => :facts, :complete_value => true, :only_explicit => true
      scoped_search :in => :search_parameters, :on => :value, :on_key=> :name, :complete_value => true, :rename => :params, :ext_method => :search_by_params, :only_explicit => true

      scoped_search :in => :location, :on => :title, :rename => :location, :complete_value => true         if SETTINGS[:locations_enabled]
      scoped_search :in => :organization, :on => :title, :rename => :organization, :complete_value => true if SETTINGS[:organizations_enabled]
      scoped_search :in => :config_groups, :on => :name, :complete_value => true, :rename => :config_group, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_config_group

      if SETTINGS[:unattended]
        scoped_search :in => :subnet,          :on => :network,     :complete_value => true, :rename => :subnet
        scoped_search :in => :subnet,          :on => :name,        :complete_value => true, :rename => 'subnet.name'
        scoped_search :on => :mac,                                  :complete_value => true
        scoped_search :on => :uuid,                                 :complete_value => true
        scoped_search :on => :build,                                :complete_value => {:true => true, :false => false}
        scoped_search :on => :installed_at,                         :complete_value => true, :only_explicit => true
        scoped_search :in => :operatingsystem, :on => :name,        :complete_value => true, :rename => :os
        scoped_search :in => :operatingsystem, :on => :description, :complete_value => true, :rename => :os_description
        scoped_search :in => :operatingsystem, :on => :major,       :complete_value => true, :rename => :os_major
        scoped_search :in => :operatingsystem, :on => :minor,       :complete_value => true, :rename => :os_minor
        scoped_search :in => :operatingsystem, :on => :id,          :complete_value => false,:rename => :os_id, :complete_enabled => false
      end

      if SETTINGS[:login]
        scoped_search :in => :search_users, :on => :login,     :complete_value => true, :only_explicit => true, :rename => :'user.login',    :operators => ['= ', '~ '], :ext_method => :search_by_user
        scoped_search :in => :search_users, :on => :firstname, :complete_value => true, :only_explicit => true, :rename => :'user.firstname',:operators => ['= ', '~ '], :ext_method => :search_by_user
        scoped_search :in => :search_users, :on => :lastname,  :complete_value => true, :only_explicit => true, :rename => :'user.lastname', :operators => ['= ', '~ '], :ext_method => :search_by_user
        scoped_search :in => :search_users, :on => :mail,      :complete_value => true, :only_explicit => true, :rename => :'user.mail',     :operators => ['= ', '~ '], :ext_method => :search_by_user
      end
    end

    module ClassMethods

      def search_by_user(key, operator, value)
        key_name = User.connection.quote_column_name(key.sub(/^.*\./,''))
        condition = sanitize_sql_for_conditions(["#{key_name} #{operator} ?", value_to_sql(operator, value)])
        users = User.all(:conditions => condition)
        hosts = users.map(&:hosts).flatten
        opts  = hosts.empty? ? "< 0" : "IN (#{hosts.map(&:id).join(',')})"

        return {:conditions => " hosts.id #{opts} " }
      end

      def search_by_puppetclass(key, operator, value)
        conditions  = sanitize_sql_for_conditions(["puppetclasses.name #{operator} ?", value_to_sql(operator, value)])
        hosts       = Host.authorized(:view_hosts, Host).where(conditions).joins(:puppetclasses).uniq.map(&:id)
        host_groups = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).joins(:puppetclasses).uniq.map(&:subtree_ids).flatten.uniq

        opts = ''
        opts += "hosts.id IN(#{hosts.join(',')})"             unless hosts.blank?
        opts += " OR "                                        unless hosts.blank? || host_groups.blank?
        opts += "hostgroups.id IN(#{host_groups.join(',')})"  unless host_groups.blank?
        opts = "hosts.id < 0"                                 if hosts.blank? && host_groups.blank?
        return {:conditions => opts, :include => :hostgroup}
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
        return {:conditions => conditions}
      end

      def search_by_config_group(key, operator, value)
        conditions  = sanitize_sql_for_conditions(["config_groups.name #{operator} ?", value_to_sql(operator, value)])
        host_ids      = Host::Managed.authorized(:view_hosts, Host).where(conditions).joins(:config_groups).uniq.map(&:id)
        hostgroup_ids = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).joins(:config_groups).uniq.map(&:subtree_ids).flatten.uniq

        opts = ''
        opts += "hosts.id IN(#{host_ids.join(',')})"             unless host_ids.blank?
        opts += " OR "                                        unless host_ids.blank? || hostgroup_ids.blank?
        opts += "hostgroups.id IN(#{hostgroup_ids.join(',')})"  unless hostgroup_ids.blank?
        opts = "hosts.id < 0"                                 if host_ids.blank? && hostgroup_ids.blank?
        return {:conditions => opts, :include => :hostgroup}
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
