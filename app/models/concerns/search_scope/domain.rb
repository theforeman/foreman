module SearchScope
  module Domain
    extend ActiveSupport::Concern

    included do
      scoped_search :on => [:name, :fullname], :complete_value => true
      scoped_search :on => :hosts_count
      scoped_search :on => :hostgroups_count
      scoped_search :in => :domain_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params
    end
  end
end

