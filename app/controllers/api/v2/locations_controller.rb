module Api
  module V2
    class LocationsController < V2::BaseController

      apipie_concern_subst(:a_resource => "a location", :resource => "location")
      include Api::V2::TaxonomiesController

    end
  end
end
