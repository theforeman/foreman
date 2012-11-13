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
        param :ip, String, :required => true
        param :mac, String, :required => true
        param :architecture_id, String, :required => true
        param :domain_id, String, :required => true
        param :puppet_proxy_id, String, :required => true
        param :operatingsystem_id, String, :required => false
        param :medium_id, String, :required => false
        param :ptable_id, String, :required => false
        param :subnet_id, String, :required => false
        param :sp_subnet_id, String, :required => false
        param :model_id_id, String, :required => false
        param :hostgroup_id, String, :required => false
        param :owner_id, String, :required => false
        param :puppet_ca_proxy_id, String, :required => false
        param :image_id, String, :required => false
        param :host_parameters_attributes, Array, :required => false
      end
      def create
        @host = Host.new(params[:host])
        @host.managed = true
        forward_request_url
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", "Update a host."
      param :id, String, :required => true
      param :host, Hash, :required => true do
        param :name, String
        param :environment_id, String
        param :ip, String
        param :mac, String
        param :architecture_id, String
        param :domain_id, String
        param :puppet_proxy_id, String
        param :operatingsystem_id, String
        param :medium_id, String
        param :ptable_id, String
        param :subnet_id, String
        param :sp_subnet_id, String
        param :model_id_id, String
        param :hostgroup_id, String
        param :owner_id, String
        param :puppet_ca_proxy_id, String
        param :image_id, String
        param :host_parameters_attributes, Array
      end
      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", "Delete an host."
      param :id, String, :required => true
      def destroy
        process_response @host.destroy
      end

      private

      # this is required for template generation (such as pxelinux) which is not done via a web request
      def forward_request_url
        @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
      end


    end
  end
end
