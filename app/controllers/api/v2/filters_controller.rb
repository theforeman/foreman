module Api
  module V2
    class FiltersController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_role
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/filters/", "List all filters."
      param :search, String, :desc => "filter results", :required => false
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @filters = resource_scope.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/filters/:id/", "Show a filter."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :filter do
        param :filter, Hash, :action_aware => true, :required => true do
          param :role_id, String, :required => true
          param :search, String
          param :permission_ids, Array
          param :organization_ids, Array
          param :location_ids, Array
        end
      end

      api :POST, "/filters/", "Create a filter."
      param_group :filter, :as => :create

      def create
        @filter = Filter.new(params[:filter])
        process_response @filter.save
      end

      api :PUT, "/filters/:id/", "Update a filter."
      param :id, String, :required => true
      param_group :filter

      def update
        process_response @filter.update_attributes(params[:filter])
      end

      api :DELETE, "/filters/:id/", "Delete a filter."
      param :id, String, :required => true

      def destroy
        process_response @filter.destroy
      end

      private

      def find_role
        @role = Role.find_by_id(role_id)
      end

      def resource_scope(controller = controller_name)
        @resource_scope ||= @role.present? ?
            @role.filters.authorized("#{action_permission}_#{controller}") :
            resource_class.scoped.authorized("#{action_permission}_#{controller}")
      end

      def role_id
        params[:role_id]
      end

    end
  end
end
