module SearchScope
  module ComputeResource
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :type, :complete_value => :true
      scoped_search :on => :id, :complete_value => :true
    end
  end
end

