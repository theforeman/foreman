module SearchScope
  module Environment
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :hosts_count
      scoped_search :on => :hostgroups_count
    end
  end
end
