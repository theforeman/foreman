module Api
  module V2
    class LocationsController < V2::BaseController

      wrap_parameters :location, :include => (Location.attribute_names + %w{parent_id organization_ids
                                  domain_ids subnet_ids hostgroup_ids config_template_ids compute_resource_ids
                                  medium_ids smart_proxy_ids environment_ids user_ids realm_ids })

      apipie_concern_subst(:a_resource => N_("a location"), :resource => "location")
      include Api::V2::TaxonomiesController
    end
  end
end
