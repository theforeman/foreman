module Api
  module V2
    class ArchitecturesController < V2::BaseController
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

      def_param_group :architecture do
        param :architecture, Hash, :action_aware => true do
          param :name, String, :required => true
          param :operatingsystem_ids, Array, :desc => "Operatingsystem ID's"
        end
      end

      api :POST, "/architectures/", "Create an architecture."
      param_group :architecture, :as => :create

      def create
        @architecture = Architecture.new(params[:architecture])
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", "Update an architecture."
      param :id, :identifier, :required => true
      param_group :architecture

      def update
        process_response @architecture.update_attributes(params[:architecture])
      end

      api :DELETE, "/architectures/:id/", "Delete an architecture."
      param :id, :identifier, :required => true

      def destroy
        process_response @architecture.destroy
      end
    end
  end
end
