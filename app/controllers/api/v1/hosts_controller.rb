module Api
  module V1
    class HostsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy status}

      api :GET, "/hosts/", "List all hosts."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @hosts = Host.
          authorized(:view_hosts, Host).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/hosts/:id/", "Show a host."
      param :id, :identifier_dottable, :required => true

      def show
      end

      api :POST, "/hosts/", "Create a host."
      param :host, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
        param :puppet_class_ids, Array
        param :operatingsystem_id, String
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :compute_resource_id, :number
        param :sp_subnet_id, :number
        param :model_id, :number
        param :hostgroup_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :host_parameters_attributes, Array
        param :build, :bool
        param :enabled, :bool
        param :provision_method, String
        param :managed, :bool
        param :progress_report_id, String, :desc => 'UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks'
        param :capabilities, String
        param :compute_attributes, Hash do
        end
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
        param :name, String
        param :environment_id, String
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
        param :operatingsystem_id, String
        param :puppet_class_ids, Array
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :compute_resource_id, :number
        param :sp_subnet_id, :number
        param :model_id, :number
        param :hostgroup_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :host_parameters_attributes, Array
        param :build, :bool
        param :enabled, :bool
        param :provision_method, String
        param :managed, :bool
        param :progress_report_id, String, :desc => 'UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks'
        param :capabilities, String
        param :compute_attributes, Hash do
        end
      end

      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", "Delete an host."
      param :id, :identifier, :required => true

      def destroy
        process_response @host.destroy
      end

      api :GET, "/hosts/:id/status", "Get status of host"
      param :id, :identifier_dottable, :required => true
      # TRANSLATORS: API documentation - do not translate
      description <<-eos
Return value may either be one of the following:

* missing
* failed
* pending
* changed
* unchanged
* unreported

      eos

      def status
        render :json => { :status => @host.host_status }.to_json if @host
      end

      private

      def resource_scope(controller)
        Host.authorized("#{action_permission}_#{controller}", Host)
      end

      # this is required for template generation (such as pxelinux) which is not done via a web request
      def forward_request_url
        @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
      end
    end
  end
end
