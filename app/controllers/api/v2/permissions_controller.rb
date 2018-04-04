module Api
  module V2
    class PermissionsController < V2::BaseController
      include Api::Version2

      before_action :find_resource, :only => %w{show}
      before_action :parameter_deprecation, :only => %w(index)

      api :GET, "/permissions/", N_("List all permissions")
      param_group :search_and_pagination, ::Api::V2::BaseController
      param :resource_type, String
      param :name, String
      add_scoped_search_description_for(Permission)

      def index
        type = params[:resource_type].presence
        name = params[:name].presence
        if type
          @permissions = Permission.where(:resource_type => type).paginate(paginate_options)
        elsif name
          @permissions = Permission.where(:name => name).paginate(paginate_options)
        else
          @permissions = resource_scope_for_index
        end
        @permissions
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

      private

      def parameter_deprecation
        return true unless params[:resource_type] || params[:name]
        Foreman::Deprecation.api_deprecation_warning(
          "The name and resource_type parameters are deprecated, use search syntax to search by those parameters."
        )
      end
    end
  end
end
