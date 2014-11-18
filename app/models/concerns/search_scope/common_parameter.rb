module SearchScope
  module CommonParameter
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :value, :complete_value => :true
    end
  end
end
