module Api
  module V1
    class HostgroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hostgroups/", "List all hostgroups."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @hostgroups = Hostgroup.
          authorized(:view_hostgroups).
          includes(:hostgroup_classes, :group_parameters).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/hostgroups/:id/", "Show a hostgroup."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/hostgroups/", "Create an hostgroup."
      param :hostgroup, Hash, :required => true do
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
        @hostgroup = Hostgroup.new(foreman_params)
        process_response @hostgroup.save
      end

      api :PUT, "/hostgroups/:id/", "Update an hostgroup."
      param :id, :identifier, :required => true
      param :hostgroup, Hash, :required => true do
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
        process_response @hostgroup.update_attributes(foreman_params)
      end

      api :DELETE, "/hostgroups/:id/", "Delete an hostgroup."
      param :id, :identifier, :required => true

      def destroy
        if @hostgroup.has_children?
          render :json => {'message'=> _("Cannot delete group %{current} because it has nested groups.") % { :current => @hostgroup.title } }, :status => :conflict
        else
          process_response @hostgroup.destroy
        end
      end
    end
  end
end
