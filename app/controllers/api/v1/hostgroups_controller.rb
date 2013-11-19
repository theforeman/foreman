module Api
  module V1
    class SystemGroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/system_groups/", "List all system_groups."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @system_groups = SystemGroup.includes(:system_group_classes, :group_parameters).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/system_groups/:id/", "Show a system_group."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/system_groups/", "Create an system_group."
      param :system_group, Hash, :required => true do
        param :name, String, :required => true
        param :parent_id, :number
        param :environment_id, :number
        param :operatingsystem_id, :number
        param :architecture_id, :number
        param :medium_id, :number
        param :ptable_id, :number
        param :puppet_ca_proxy_id, :number
        param :subnet_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
      end

      def create
        @system_group = SystemGroup.new(params[:system_group])
        process_response @system_group.save
      end

      api :PUT, "/system_groups/:id/", "Update an system_group."
      param :id, :identifier, :required => true
      param :system_group, Hash, :required => true do
        param :name, String
        param :parent_id, :number
        param :environment_id, :number
        param :operatingsystem_id, :number
        param :architecture_id, :number
        param :medium_id, :number
        param :ptable_id, :number
        param :puppet_ca_proxy_id, :number
        param :subnet_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
      end

      def update
        process_response @system_group.update_attributes(params[:system_group])
      end

      api :DELETE, "/system_groups/:id/", "Delete an system_group."
      param :id, :identifier, :required => true

      def destroy
        process_response @system_group.destroy
      end

    end
  end
end
