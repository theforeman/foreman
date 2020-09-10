module HostFacets
  class Base < ApplicationRecord
    self.abstract_class = true

    include Facets::Base
  end
end
