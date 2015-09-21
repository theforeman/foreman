module Api
  module V1
    class EnvironmentsController < V1::BaseController
      include Api::ImportPuppetclassesCommonController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", "List all environments."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @environments = Environment.
          authorized(:view_environments).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/environments/:id/", "Show an environment."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/environments/", "Create an environment."
      param :environment, Hash, :required => true do
        param :name, String, :required => true
      end

      def create
        @environment = Environment.new(foreman_params)
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", "Update an environment."
      param :id, :identifier, :required => true
      param :environment, Hash, :required => true do
        param :name, String
      end

      def update
        process_response @environment.update_attributes(foreman_params)
      end

      api :DELETE, "/environments/:id/", "Delete an environment."
      param :id, :identifier, :required => true

      def destroy
        process_response @environment.destroy
      end
    end
  end
end
