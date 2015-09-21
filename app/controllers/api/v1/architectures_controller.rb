module Api
  module V1
    class ArchitecturesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/architectures/", "List all architectures."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @architectures = Architecture.
          authorized(:view_architectures).
          includes(:operatingsystems).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/architectures/:id/", "Show an architecture."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/architectures/", "Create an architecture."
      param :architecture, Hash, :required => true do
        param :name, String, :required => true
        param :operatingsystem_ids, Array, :desc => "Operatingsystem ID's"
      end

      def create
        @architecture = Architecture.new(foreman_params)
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", "Update an architecture."
      param :id, :identifier, :required => true
      param :architecture, Hash, :required => true do
        param :name, String
        param :operatingsystem_ids, Array, :desc => "Operatingsystem ID's"
      end

      def update
        process_response @architecture.update_attributes(foreman_params)
      end

      api :DELETE, "/architectures/:id/", "Delete an architecture."
      param :id, :identifier, :required => true

      def destroy
        process_response @architecture.destroy
      end
    end
  end
end
