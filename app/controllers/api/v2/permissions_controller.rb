module Api
  module V2
    class PermissionsController < V2::BaseController
      include Api::Version2

      before_action :find_resource, :only => %w{show}

      api :GET, "/permissions/", N_("List all permissions")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Permission)

      def index
        @permissions = resource_scope_for_index
      end

      api :GET, "/permissions/:id/", N_("Show a permission")
      param :id, :identifier, :required => true

      def show
      end

      api :GET, "/permissions/resource_types/", N_("List available resource types")
      def resource_types
        @resource_types = Permission.resources
        @total = @resource_types.size
        render :resource_types, :layout => 'api/v2/layouts/index_layout'
      end
    end
  end
end
