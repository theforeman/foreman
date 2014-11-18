module Api
  module V2
    class DeploymentsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      resource_description do
        name 'Deployment'
      end

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}


      api :GET, "/deployments/", N_("List all deployments")
      api :GET, "/locations/:location_id/deployments", N_("List of deployments per location")
      api :GET, "/organizations/:organization_id/deployments", N_("List of deployments per organization")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @deployments = resource_scope_for_index
      end

      api :GET, "/deployments/:id/", N_("Show a deployment")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :deployment do
        param :deployment, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/deployments/", N_("Create a deployment")
      param_group :deployment, :as => :create

      def create
        @deployment = Deployment.new(params[:deployment])
        process_response @deployment.save
      end

      api :PUT, "/deployments/:id/", N_("Update a deployment")
      param :id, :identifier, :required => true
      param_group :deployment

      def update
        process_response @deployment.update_attributes(params[:deployment])
      end

      api :DELETE, "/deployments/:id/", N_("Delete a deployment")
      param :id, :identifier, :required => true

      def destroy
        process_response @deployment.destroy
      end

      private

      def allowed_nested_id
        %w(location_id organization_id)
      end


    end
  end
end
