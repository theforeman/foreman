module Api
  module V2
    class EnvironmentsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope
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

      def_param_group :environment do
        param :environment, Hash, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/environments/", "Create an environment."
      param_group :environment, :as => :create

      def create
        @environment = Environment.new(params[:environment])
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", "Update an environment."
      param :id, :identifier, :required => true
      param_group :environment

      def update
        process_response @environment.update_attributes(params[:environment])
      end

      api :DELETE, "/environments/:id/", "Delete an environment."
      param :id, :identifier, :required => true

      def destroy
        process_response @environment.destroy
      end
    end
  end
end
