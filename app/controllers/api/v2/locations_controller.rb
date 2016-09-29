module Api
  module V2
    class LocationsController < V2::BaseController
      apipie_concern_subst(:a_resource => N_("a location"), :resource => "location")
      include Api::V2::TaxonomiesController
      include Foreman::Controller::Parameters::Location
    end
  end
end
