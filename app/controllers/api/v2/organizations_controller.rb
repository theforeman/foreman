module Api
  module V2
    class OrganizationsController < V2::BaseController

      apipie_concern_subst(:a_resource => N_("an organization"), :resource => "organization",
                           :res_id => ":organization_id", :opp_resource => "location", :opp_resources => "locations")
      include Api::V2::TaxonomiesController

    end
  end
end
