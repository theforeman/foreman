module NestedAncestryCommon::Search
  extend ActiveSupport::Concern

  included do
    scoped_search :on => :title, :complete_value => true, :default_order => true
    scoped_search :on => :name, :complete_value => :true
  end
end
