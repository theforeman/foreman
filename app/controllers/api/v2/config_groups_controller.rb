module Api
  module V2
    class ConfigGroupsController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/config_groups", N_("List of config groups")
      def index
      end

      api :GET, "/config_groups/:id/", N_("Show a config group")
      def show
      end

      api :POST, "/config_groups/", N_("Create a config group")
      def create
      end

      api :PUT, "/config_groups/:id/", N_("Update a config group")
      def update
      end

      api :DELETE, "/config_groups/:id/", N_("Delete a config group")
      def destroy
      end
    end
  end
end
