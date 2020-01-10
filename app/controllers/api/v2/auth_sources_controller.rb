module Api
  module V2
    class AuthSourcesController < V2::BaseController
      before_action :find_resource, :only => %w{show}

      api :GET, "/auth_sources/", N_("List all authentication sources")
      api :GET, '/locations/:location_id/auth_sources/', N_('List all authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_sources/', N_('List all authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(AuthSource)

      def index
        @auth_sources = resource_scope_for_index.except_hidden
      end

      def resource_scope(*args)
        super.except_hidden
      end

      def controller_permission
        'authenticators'
      end
    end
  end
end
