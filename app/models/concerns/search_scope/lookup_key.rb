module SearchScope
  module LookupKey
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :key, :complete_value => true, :default_order => true
      scoped_search :on => :lookup_values_count, :rename => :values_count
      scoped_search :on => :override, :complete_value => {:true => true, :false => false}
      scoped_search :on => :merge_overrides, :complete_value => {:true => true, :false => false}
      scoped_search :on => :avoid_duplicates, :complete_value => {:true => true, :false => false}
      scoped_search :in => :param_classes, :on => :name, :rename => :puppetclass, :complete_value => true
      scoped_search :in => :lookup_values, :on => :value, :rename => :value, :complete_value => true
    end
  end
end
