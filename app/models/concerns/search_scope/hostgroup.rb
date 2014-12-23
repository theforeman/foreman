module SearchScope
  module Hostgroup
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions

      scoped_search :on => :name, :complete_value => :true
      scoped_search :in => :group_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params
      scoped_search :in => :hosts, :on => :name, :complete_value => :true, :rename => "host"
      scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :operators => ['= ', '~ ']
      scoped_search :in => :environment, :on => :name, :complete_value => :true, :rename => :environment
      scoped_search :on => :id, :complete_value => :true
      # for legacy purposes, keep search on :label
      scoped_search :on => :title, :complete_value => true, :rename => :label
      scoped_search :in => :config_groups, :on => :name, :complete_value => true, :rename => :config_group, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_config_group
      if SETTINGS[:unattended]
        scoped_search :in => :architecture, :on => :name, :complete_value => :true, :rename => :architecture
        scoped_search :in => :operatingsystem, :on => :name, :complete_value => true, :rename => :os
        scoped_search :in => :operatingsystem,  :on => :description, :complete_value => true,  :rename => :os_description
        scoped_search :in => :operatingsystem,  :on => :title,       :complete_value => true,  :rename => :os_title
        scoped_search :in => :operatingsystem,  :on => :major,       :complete_value => true,  :rename => :os_major
        scoped_search :in => :operatingsystem,  :on => :minor,       :complete_value => true,  :rename => :os_minor
        scoped_search :in => :operatingsystem,  :on => :id,          :complete_value => false, :rename => :os_id, :complete_enabled => false
        scoped_search :in => :medium,            :on => :name, :complete_value => :true, :rename => "medium"
        scoped_search :in => :config_templates, :on => :name, :complete_value => :true, :rename => "template"
      end
    end

    module ClassMethods
      def search_by_config_group(key, operator, value)
        conditions  = sanitize_sql_for_conditions(["config_groups.name #{operator} ?", value_to_sql(operator, value)])
        hostgroup_ids = ::Hostgroup.unscoped.with_taxonomy_scope.joins(:config_groups).where(conditions).map(&:subtree_ids).flatten.uniq

        opts = 'hostgroups.id < 0'
        opts = "hostgroups.id IN(#{hostgroup_ids.join(',')})" unless hostgroup_ids.blank?
        {:conditions => opts}
      end
    end
  end
end
