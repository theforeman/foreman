module Api
  module V1
    class ArchitecturesController < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_by_name, :only => %w{show update destroy}

      api :GET, "/architectures/", "List all architectures."
      def index
        @architectures = Architecture.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :include => :operatingsystems)
      end

      api :GET, "/architectures/:id/", "Show an architecture."
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
      param :architecture, Hash, :required => true do
          param :name, String
      end
      def update
        process_response @architecture.update_attributes(params[:architecture])
      end

      api :DELETE, "/architecturess/:id/", "Delete an architecture."
      def destroy
        process_response @architecture.destroy
      end
    end
  end
end
