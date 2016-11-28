module HostFacets
  class Base < ActiveRecord::Base
    self.abstract_class = true

    include Facets::Base
  end
end
