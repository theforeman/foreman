module SearchScope
  module Model
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true, :default_order => true
      scoped_search :on => :info
      scoped_search :on => :hosts_count
      scoped_search :on => :vendor_class, :complete_value => :true
      scoped_search :on => :hardware_model, :complete_value => :true
    end
  end
end
