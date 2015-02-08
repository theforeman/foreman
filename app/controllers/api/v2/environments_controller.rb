module Api
  module V2
    class EnvironmentsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope
      include Api::ImportPuppetclassesCommonController

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", N_("List all environments")
      api :GET, "/puppetclasses/:puppetclass_id/environments", N_("List environments of Puppet class")
      api :GET, "/locations/:location_id/environments", N_("List environments per location")
      api :GET, "/organizations/:organization_id/environments", N_("List environments per organization")
      param :puppetclass_id, String, :desc => N_("ID of Puppet class")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @environments = resource_scope_for_index
      end

      api :GET, "/environments/:id/", N_("Show an environment")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :environment do
        param :environment, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
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

      api :POST, "/environments/:environment_id/links/locations", N_("Add location to environment")
      api :POST, "/environments/:environment_id/links/organizations", N_("Add organization to environment")
      param :environment_id, :identifier, :required => true
      param_group :taxonomies_associations, ::Api::V2::BaseController
      def add
      end

      api :DELETE, "/environments/:environment_id/links/locations/:id", N_("Remove location from environment")
      api :DELETE, "/environments/:environment_id/links/organizations/:id", N_("Remove organization from environment")
      param :environment_id, :identifier, :required => true
      param :id, String, :required => true, :desc => N_("ID or comma-delimited list of IDs")
      def remove
      end

      private

      def allowed_nested_id
        %w(puppetclass_id location_id organization_id)
      end

    end
  end
end
