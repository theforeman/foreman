module SearchScope
  module Puppetclass
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions

      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :total_hosts
      scoped_search :on => :global_class_params_count, :rename => :params_count   # Smart Parameters
      scoped_search :on => :lookup_keys_count, :rename => :variables_count        # Smart Variables
      scoped_search :in => :environments, :on => :name, :complete_value => :true, :rename => "environment"
      scoped_search :in => :hostgroups,   :on => :name, :complete_value => :true, :rename => "hostgroup"
      scoped_search :in => :config_groups,   :on => :name, :complete_value => :true, :rename => "config_group"
      scoped_search :in => :hosts, :on => :name, :complete_value => :true, :rename => "host", :ext_method => :search_by_host, :only_explicit => true
      scoped_search :in => :class_params, :on => :key, :complete_value => :true, :only_explicit => true
    end
  end
end
