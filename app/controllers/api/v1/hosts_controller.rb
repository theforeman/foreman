module Api
  module V1
    class HostsController < V1::BaseController
      include Foreman::Controller::HostDetails
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hosts/", "List all hosts."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      def index
        @hosts = Host.my_hosts.search_for(params[:search],:order => params[:order])
      end

      api :GET, "/hosts/:id/", "Show a host."
      param :id, String, :required => true
      def show
      end

      api :POST, "/hosts/", "Create a host."
      param :host, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => true
        param :operatingsystem_id, String, :required => false
        param :architecture_id, String, :required => false
        param :medium_id, String, :required => false
        param :ptable_id, String, :required => false
        param :subnet_id, String, :required => false
        param :sp_subnet_id, String, :required => false
        param :model_id_id, String, :required => false
        param :hostgroup_id, String, :required => false
        param :owner_id, String, :required => false
        param :puppet_ca_proxy_id, String, :required => false
        param :puppet_proxy_id, String, :required => false
        param :image_id, String, :required => false
        param :host_parameters_attributes, Array, :required => false
      end
      def create
        @host = Host.new(params[:host])
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", "Update a host."
      param :id, String, :required => true
      param :host, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => true
        param :operatingsystem_id, String, :required => false
        param :architecture_id, String, :required => false
        param :medium_id, String, :required => false
        param :ptable_id, String, :required => false
        param :subnet_id, String, :required => false
        param :sp_subnet_id, String, :required => false
        param :model_id_id, String, :required => false
        param :hostgroup_id, String, :required => false
        param :owner_id, String, :required => false
        param :puppet_ca_proxy_id, String, :required => false
        param :puppet_proxy_id, String, :required => false
        param :image_id, String, :required => false
        param :host_parameters_attributes, Array, :required => false
      end
      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", "Delete an host."
      param :id, String, :required => true
      def destroy
        process_response @host.destroy
      end

    end
  end
end
