module Api
  module V2
    class FiltersController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/filters/", N_("List all filters")
      param :search, String, :desc => N_("filter results"), :required => false
      param :order, String, :desc => N_("sort results"), :required => false
      param :page, String, :desc => N_("paginate results"), :required => false
      param :per_page, String, :desc => N_("number of entries per request"), :required => false

      def index
        @filters = resource_scope.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/filters/:id/", N_("Show a filter")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :filter do
        param :filter, Hash, :required => true, :action_aware => true, :required => true do
          param :role_id, String, :required => true
          param :search, String
          param :permission_ids, Array
          param :organization_ids, Array
          param :location_ids, Array
        end
      end

      api :POST, "/filters/", N_("Create a filter")
      param_group :filter, :as => :create

      def create
        @filter = nested_obj ? nested_obj.filters.build(params[:filter]) : Filter.new(params[:filter])
        process_response @filter.save
      end

      api :PUT, "/filters/:id/", N_("Update a filter")
      param :id, String, :required => true
      param_group :filter

      def update
        process_response @filter.update_attributes(params[:filter])
      end

      api :DELETE, "/filters/:id/", N_("Delete a filter")
      param :id, String, :required => true

      def destroy
        process_response @filter.destroy
      end

      private

      def allowed_nested_id
        %w(role_id)
      end

      def resource_scope(controller = controller_name)
        @resource_scope ||= nested_obj.present? ?
            nested_obj.filters.authorized("#{action_permission}_#{controller}") :
            resource_class.scoped.authorized("#{action_permission}_#{controller}")
      end

    end
  end
end
