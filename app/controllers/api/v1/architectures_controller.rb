module Api
  module V1
    class ArchitecturesController < V1::BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/architectures/", "List all architectures."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @architectures = Architecture.search_for(params[:search], :order => params[:order]).
            paginate(:page => params[:page], :include => :operatingsystems)
      end

      api :GET, "/architectures/:id/", "Show an architecture."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/architectures/", "Create an architecture."
      param :architecture, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @architecture = Architecture.new(params[:architecture])
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", "Update an architecture."
      param :id, String, :required => true
      param :architecture, Hash, :required => true do
        param :name, String
      end
      def update
        process_response @architecture.update_attributes(params[:architecture])
      end

      api :DELETE, "/architectures/:id/", "Delete an architecture."
      param :id, String, :required => true
      def destroy
        process_response @architecture.destroy
      end
    end
  end
end
