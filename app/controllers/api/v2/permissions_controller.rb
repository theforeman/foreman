module Api
  module V2
    class PermissionsController < V2::BaseController
      before_filter :find_resource, :only => %w{show}

      api :GET, "/permissions/", "List all permissions."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      param :resource_type, String
      param :name, String

      def index
        type = params[:resource_type].blank? ? nil : params[:resource_type]
        name = params[:name].blank? ? nil : params[:name]
        if type
          @permissions = Permission.find_all_by_resource_type(type)
        elsif name
          @permissions = Permission.find_all_by_name(name)
        else
          @permissions = Permission.all
        end
        @permissions = @permissions.paginate(paginate_options)
      end

      api :GET, "/permissions/:id/", "Show a permission."
      param :id, :identifier, :required => true

      def show
      end

      api :GET, "/permissions/resource_types/", "List available resource types."
      def resource_types
        @resource_types = Permission.resources
        @total = @resource_types.size
        render :resource_types, :layout => 'api/v2/layouts/index_layout'
      end

    end
  end
end
