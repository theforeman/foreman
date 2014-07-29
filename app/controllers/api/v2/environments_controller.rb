module Api
  module V2
    class EnvironmentsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope
      include Api::ImportPuppetclassesCommonController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", N_("List all environments")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @environments = Environment.
          authorized(:view_environments).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/environments/:id/", N_("Show an environment")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :environment do
        param :environment, Hash, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/environments/", N_("Create an environment")
      param_group :environment, :as => :create

      def create
        @environment = Environment.new(params[:environment])
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", N_("Update an environment")
      param :id, :identifier, :required => true
      param_group :environment

      def update
        process_response @environment.update_attributes(params[:environment])
      end

      api :DELETE, "/environments/:id/", N_("Delete an environment")
      param :id, :identifier, :required => true

      def destroy
        process_response @environment.destroy
      end
    end
  end
end
