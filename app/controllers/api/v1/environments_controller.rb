module Api
  module V1
    class EnvironmentsController < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", "List all environments."
      def index
        @environments = Environment.search_for(params[:search], :order => params[:order]).
            paginate :page => params[:page]
      end

      api :GET, "/environments/:id/", "Show an environment."
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
      param :environment, Hash, :required => true do
        param :name, String
      end
      def update
        process_response @environment.update_attributes(params[:environment])
      end

      api :DELETE, "/environments/:id/", "Delete an environment."
      def destroy
        process_response @environment.destroy
      end
    end
  end
end