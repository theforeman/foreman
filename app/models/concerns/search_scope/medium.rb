module SearchScope
  module Medium
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true, :default_order => true
      scoped_search :on => :path, :complete_value => :true
      scoped_search :on => :os_family, :rename => "family", :complete_value => :true
    end
  end
end

