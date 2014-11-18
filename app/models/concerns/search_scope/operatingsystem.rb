module SearchScope
  module Operatingsystem
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name,        :complete_value => :true
      scoped_search :on => :major,       :complete_value => :true
      scoped_search :on => :minor,       :complete_value => :true
      scoped_search :on => :description, :complete_value => :true
      scoped_search :on => :type,        :complete_value => :true, :rename => "family"
      scoped_search :on => :title,       :complete_value => :true
      scoped_search :on => :hosts_count
      scoped_search :on => :hostgroups_count

      scoped_search :in => :architectures,    :on => :name,  :complete_value => :true, :rename => "architecture", :only_explicit => true
      scoped_search :in => :media,            :on => :name,  :complete_value => :true, :rename => "medium", :only_explicit => true
      scoped_search :in => :config_templates, :on => :name,  :complete_value => :true, :rename => "template", :only_explicit => true
      scoped_search :in => :os_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :rename => :params, :only_explicit => true

    end
  end
end
