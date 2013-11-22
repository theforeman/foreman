module Host
  module Hostmix

      def has_many_hosts(options = {})
        has_many :hosts, {:class_name => "Host::Managed"}.merge(options)
        alias_attribute :systems, :hosts
        alias_attribute :system_ids, :host_ids
      end

      def belongs_to_host(options = {})
        belongs_to :host, {:class_name => "Host::Managed", :foreign_key => :host_id}.merge(options)
        belongs_to :system, {:class_name => "Host::Managed", :foreign_key => :host_id}.merge(options)
        alias_attribute :system_id, :host_id
      end

      def has_many_hostgroups(options = {})
        has_many :hostgroups, {}.merge(options)
        alias_attribute :system_groups, :hostgroups
        alias_attribute :system_group_ids, :hostgroup_ids
      end

      def belongs_to_hostgroup(options = {})
        belongs_to :hostgroup, {}.merge(options)
        alias_attribute :system_group, :hostgroup
        alias_attribute :system_group_id, :hostgroup_id
      end

  end
end