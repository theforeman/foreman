module Api
  module V1
    class HostgroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hostgroups/", "List all hostgroups."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @hostgroups = Hostgroup.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/hostgroups/:id/", "Show a hostgroup."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/hostgroups/", "Create an hostgroup."
      param :hostgroup, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => false
        param :operatingsystem_id, String, :required => false
        param :architecture_id, String, :required => false
        param :medium_id, String, :required => false
        param :ptable_id, String, :required => false
        param :puppet_ca_proxy_id, String, :required => false
        param :subnet_id, String, :required => false
        param :domain_id, String, :required => false
        param :puppet_proxy_id, String, :required => false
      end
      def create
        @hostgroup = Hostgroup.new(params[:hostgroup])
        process_response @hostgroup.save
      end

      api :PUT, "/hostgroups/:id/", "Update an hostgroup."
      param :id, String, :required => true
      param :hostgroup, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => false
        param :operatingsystem_id, String, :required => false
        param :architecture_id, String, :required => false
        param :medium_id, String, :required => false
        param :ptable_id, String, :required => false
        param :puppet_ca_proxy_id, String, :required => false
        param :subnet_id, String, :required => false
        param :domain_id, String, :required => false
        param :puppet_proxy_id, String, :required => false
      end
      def update
        process_response @hostgroup.update_attributes(params[:hostgroup])
      end

      api :DELETE, "/hostgroups/:id/", "Delete an hostgroup."
      param :id, String, :required => true
      def destroy
        process_response @hostgroup.destroy
      end

    end
  end
end
