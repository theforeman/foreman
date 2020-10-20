module Api
  module V2
    class EnvironmentsController < V2::BaseController
      include Api::ImportPuppetclassesCommonController
      include Api::V2::ExtractedPuppetController

      api :GET, "/environments/", N_("List all environments")
      api :GET, "/puppetclasses/:puppetclass_id/environments", N_("List environments of Puppet class")
      api :GET, "/locations/:location_id/environments", N_("List environments per location")
      api :GET, "/organizations/:organization_id/environments", N_("List environments per organization")
      def index
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
      end

      api :PUT, "/environments/:id/", N_("Update an environment")
      param :id, :identifier, :required => true
      param_group :environment

      def update
      end

      api :DELETE, "/environments/:id/", N_("Delete an environment")
      param :id, :identifier, :required => true

      def destroy
      end
    end
  end
end
