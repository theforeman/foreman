module Api
  module V1
    class EnvironmentsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", "List all environments."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      def index
        @environments = Environment.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/environments/:id/", "Show an environment."
      param :id, String, :required => true
      def show
      end

      api :POST, "/environments/", "Create an environment."
      param :environment, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @environment = Environment.new(params[:environment])
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", "Update an environment."
      param :id, String, :required => true
      param :environment, Hash, :required => true do
        param :name, String
      end
      def update
        process_response @environment.update_attributes(params[:environment])
      end

      api :DELETE, "/environments/:id/", "Delete an environment."
      param :id, String, :required => true
      def destroy
        process_response @environment.destroy
      end
    end
  end
end
