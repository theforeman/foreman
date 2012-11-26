module Api
  module V1
    class HostsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hosts/", "List all hosts."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @hosts = Host.my_hosts.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/hosts/:id/", "Show a host."
      param :id, :identifier_dottable, :required => true

      def show
      end

      api :POST, "/hosts/", "Create a host."
      param :host, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => true
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number, :required => true
        param :domain_id, :number, :required => true
        param :puppet_proxy_id, :number, :required => true
        param :operatingsystem_id, String, :required => true
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :sp_subnet_id, :number
        param :model_id_id, :number
        param :hostgroup_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :host_parameters_attributes, Array
      end

      def create
        @host = Host.new(params[:host])
        @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        forward_request_url
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", "Update a host."
      param :id, :identifier, :required => true
      param :host, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String, :required => true
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number, :required => true
        param :domain_id, :number, :required => true
        param :puppet_proxy_id, :number, :required => true
        param :operatingsystem_id, String, :required => true
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :sp_subnet_id, :number
        param :model_id_id, :number
        param :hostgroup_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :host_parameters_attributes, Array
      end

      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", "Delete an host."
      param :id, :identifier, :required => true

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
