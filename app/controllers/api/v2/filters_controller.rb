module Api
  module V2
    class FiltersController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Filter

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/filters/", N_("List all filters")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Filter)

      def index
        @filters = resource_scope_for_index
      end

      api :GET, "/filters/:id/", N_("Show a filter")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :filter do
        param :filter, Hash, :action_aware => true, :required => true do
          param :role_id, String, :required => true
          param :search, String
          param :override, :bool
          param :permission_ids, Array
          param :organization_ids, Array
          param :location_ids, Array
        end
      end

      api :POST, "/filters/", N_("Create a filter")
      param_group :filter, :as => :create

      def create
        @filter = nested_obj.respond_to?(:filters) ? nested_obj.filters.build(filter_params) : Filter.new(filter_params)
        process_response @filter.save
      end

      api :PUT, "/filters/:id/", N_("Update a filter")
      param :id, String, :required => true
      param_group :filter

      def update
        process_response @filter.update(filter_params)
      end

      api :DELETE, "/filters/:id/", N_("Delete a filter")
      param :id, String, :required => true

      def destroy
        process_response @filter.destroy
      end

      def resource_scope(*args)
        resource_class.unscoped
      end

      private

      def allowed_nested_id
        %w(role_id)
      end
    end
  end
end
