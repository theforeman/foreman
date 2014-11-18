module SearchScope
  module ConfigTemplate
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name,    :complete_value => true, :default_order => true
      scoped_search :on => :locked,  :complete_value => true, :complete_value => {:true => true, :false => false}
      scoped_search :on => :snippet, :complete_value => true, :complete_value => {:true => true, :false => false}
      scoped_search :on => :template

      scoped_search :in => :operatingsystems, :on => :name, :rename => :operatingsystem, :complete_value => true
      scoped_search :in => :environments,     :on => :name, :rename => :environment,     :complete_value => true
      scoped_search :in => :hostgroups,       :on => :name, :rename => :hostgroup,       :complete_value => true
      scoped_search :in => :template_kind,    :on => :name, :rename => :kind,            :complete_value => true
    end
  end
end
