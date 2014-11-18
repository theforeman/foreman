module SearchScope
  module Setting
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :description, :complete_value => :true
    end
  end
end
