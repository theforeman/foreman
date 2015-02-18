module Api
  module V2
    class ConfigGroupsController < V2::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/config_groups", N_("List of config groups")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @config_groups = resource_scope_for_index
      end

      api :GET, "/config_groups/:id/", N_("Show a config group")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :config_group do
        param :config_group, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/config_groups/", N_("Create a config group")
      param_group :config_group, :as => :create

      def create
        @config_group = ConfigGroup.new(params[:config_group])
        process_response @config_group.save
      end

      api :PUT, "/config_groups/:id/", N_("Update a config group")
      param :id, String, :required => true
      param_group :config_group

      def update
        process_response @config_group.update_attributes(params[:config_group])
      end

      api :DELETE, "/config_groups/:id/", N_("Delete a config group")
      param :id, String, :required => true

      def destroy
        process_response @config_group.destroy
      end
    end
  end
end
