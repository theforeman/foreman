module Api
  module V2
    class FiltersController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/filters/", "List all filters."
      param :search, String, :desc => "filter results", :required => false
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @filters = Filter.authorized(:view_filters).search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/filters/:id/", "Show an filter."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/filters/", "Create an filter."
      param :filter, Hash, :required => true do
        param :role_id, String, :required => true
        param :search, String
        param :permission_ids, Array
        param :organization_ids, Array
        param :location_ids, Array
      end

      def create
        @filter = Filter.new(params[:filter])
        process_response @filter.save
      end

      api :PUT, "/filters/:id/", "Update an filter."
      param :id, String, :required => true
      param :filter, Hash, :required => true do
        param :search, String
        param :permission_ids, Array
        param :organization_ids, Array
        param :location_ids, Array
      end

      def update
        process_response @filter.update_attributes(params[:filter])
      end

      api :DELETE, "/filters/:id/", "Delete an filter."
      param :id, String, :required => true

      def destroy
        process_response @filter.destroy
      end
    end
  end
end
