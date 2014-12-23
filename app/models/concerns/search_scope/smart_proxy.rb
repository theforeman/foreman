module SearchScope
  module SmartProxy
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => :true
      scoped_search :on => :url, :complete_value => :true
      scoped_search :in => :features, :on => :name, :rename => :feature, :complete_value => :true
    end
  end
end

