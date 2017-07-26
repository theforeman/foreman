module Api
  module V2
    class AuthSourceController < V2::BaseController
      include Api::TaxonomyScope

      before_action :find_resource, :only => %w{show}

      api :GET, "/auth_source/", N_("List all authentication sources")
      api :GET, '/locations/:location_id/auth_source/',
          N_('List authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source/',
          N_('List authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @auth_source = resource_scope_for_index
      end

      api :GET, "/auth_source/:id/", N_("Show all authentication sources")
      param :id, :identifier, :required => true

      def show
      end
    end
  end
end
