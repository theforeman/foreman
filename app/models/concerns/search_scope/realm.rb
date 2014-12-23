module SearchScope
  module Realm
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :hosts_count
      scoped_search :on => :name, :complete_value => true
      scoped_search :on => :realm_type, :complete_value => true, :rename => :type
    end
  end
end
