module Api
  module V2
    class EnvironmentsController < V2::BaseController
      include Api::Version2
      include Api::ImportPuppetclassesCommonController
      include Foreman::Controller::Parameters::Environment

      resource_description do
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/environments/", N_("List all environments")
      api :GET, "/puppetclasses/:puppetclass_id/environments", N_("List environments of Puppet class")
      api :GET, "/locations/:location_id/environments", N_("List environments per location")
      api :GET, "/organizations/:organization_id/environments", N_("List environments per organization")
      param :puppetclass_id, String, :desc => N_("ID of Puppet class")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Environment)

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
        @environment = Environment.new(environment_params)
        process_response @environment.save
      end

      api :PUT, "/environments/:id/", N_("Update an environment")
      param :id, :identifier, :required => true
      param_group :environment

      def update
        process_response @environment.update(environment_params)
      end

      api :DELETE, "/environments/:id/", N_("Delete an environment")
      param :id, :identifier, :required => true

      def destroy
        process_response @environment.destroy
      end

      private

      def action_permission
        case params[:action]
        when 'import_puppetclasses'
          :import_puppetclasses
        else
          super
        end
      end

      def parent_permission(child_permission)
        case child_permission.to_s
        when 'import_puppetclasses'
          :view
        else
          super
        end
      end

      def allowed_nested_id
        %w(puppetclass_id location_id organization_id)
      end
    end
  end
end
