module SearchScope
  module Taxonomix
    extend ActiveSupport::Concern

    included do
      scoped_search :in => :locations, :on => :name, :rename => :location, :complete_value => true
      scoped_search :in => :locations, :on => :id, :rename => :location_id, :complete_value => true
      scoped_search :in => :organizations, :on => :name, :rename => :organization, :complete_value => true
      scoped_search :in => :organizations, :on => :id, :rename => :organization_id, :complete_value => true
    end
  end
end
