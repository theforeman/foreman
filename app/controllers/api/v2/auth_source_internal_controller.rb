module Api
  module V2
    class AuthSourceInternalController < V2::BaseController
      include Api::TaxonomyScope
      before_action :find_resource, :only => %w{show}

      api :GET, "/auth_source_internal/", N_("List internal audits")
      api :GET, '/locations/:location_id/auth_source_internal/',
          N_('List internal authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source_internal/',
          N_('List internal authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @auth_source_internal = resource_scope_for_index
      end

      api :GET, "/auth_source_internal/:id/", N_("Show an internal authentication sources")
      param :id, :identifier, :required => true

      def show
      end
    end
  end
end
