module SearchScope
  module Architecture
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :hosts_count
    end
  end
end
