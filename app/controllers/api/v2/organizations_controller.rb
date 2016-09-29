module Api
  module V2
    class OrganizationsController < V2::BaseController
      apipie_concern_subst(:a_resource => N_("an organization"), :resource => "organization")
      include Api::V2::TaxonomiesController
      include Foreman::Controller::Parameters::Organization
    end
  end
end
