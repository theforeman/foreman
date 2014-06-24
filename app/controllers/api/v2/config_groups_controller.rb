module Api
  module V2
    class ConfigGroupsController < V2::BaseController

      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/config_groups", "List of config groups"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"

      def index
        @config_groups = ConfigGroup.authorized(:view_config_groups).search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/config_groups/:id/", "Show a config group."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :config_group do
        param :config_group, Hash, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/config_groups/", "Create a config group."
      param_group :config_group, :as => :create

      def create
        @config_group = ConfigGroup.new(params[:config_group])
        process_response @config_group.save
      end

      api :PUT, "/config_groups/:id/", "Update a config group."
      param :id, String, :required => true
      param_group :config_group

      def update
        process_response @config_group.update_attributes(params[:config_group])
      end

      api :DELETE, "/config_groups/:id/", "Delete a config group."
      param :id, String, :required => true

      def destroy
        process_response @config_group.destroy
      end

    end
  end
end
