module Api
  module V1
    class HostsController < V1::BaseController
      include Api::CompatibilityChecker
      include Foreman::Controller::Parameters::Host
      include Api::LookupValueConnectorController

      before_action :check_create_host_nested, :only => [:create, :update]
      before_action :find_resource, :only => %w{show update destroy status}

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
        param :location_id, :number, :required => true, :desc => "required if locations are enabled" if SETTINGS[:locations_enabled]
        param :organization_id, :number, :required => true, :desc => "required if organizations are enabled" if SETTINGS[:organizations_enabled]
        param :environment_id, String, :desc => "required if host is managed and value is not inherited from host group"
        param :ip, String, :desc => "IPv4 address"
        param :ip6, String, :desc => "IPv6 address"
        param :mac, String, :desc => "required for managed host that is bare metal, not required if it's a virtual machine"
        param :architecture_id, :number, :desc => "required if host is managed and value is not inherited from host group"
        param :domain_id, :number, :desc => "required if host is managed and value is not inherited from host group"
        param :realm_id, :number
        param :puppet_proxy_id, :number
        param :puppetclass_ids, Array
        param :operatingsystem_id, String, :desc => "required if host is managed and value is not inherited from host group"
        param :medium_id, String, :desc => "required if not imaged based provisioning and host is managed and value is not inherited from host group"
        param :pxe_loader, Operatingsystem.all_loaders, :desc => N_("DHCP filename option")
        param :ptable_id, :number, :desc => "required if host is managed and custom partition has not been defined"
        param :subnet_id, :number, :desc => "IPv4 subnet"
        param :subnet6_id, :number, :desc => "IPv6 subnet"
        param :compute_resource_id, :number, :desc => "nil means host is bare metal"
        param :root_pass, String, :desc => "required if host is managed and value is not inherited from host group or default password in settings"
        param :model_id, :number
        param :hostgroup_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :host_parameters_attributes, Array, :desc => "Host's parameters (array or indexed hash)" do
          param :name, String, :desc => "Name of the parameter", :required => true
          param :value, String, :desc => "Parameter value", :required => true
        end
        param :build, :bool
        param :enabled, :bool
        param :provision_method, String
        param :managed, :bool, :desc => "True/False flag whether a host is managed or unmanaged. Note: this value also determines whether several parameters are required or not"
        param :progress_report_id, String, :desc => "UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks"
        param :comment, String, :desc => "Additional information about this host"
        param :capabilities, String
        param :compute_profile_id, :number
        param :compute_attributes, Hash do
        end
      end

      def create
        lookup_values = turn_params_to_values(host_params[:host_parameters_attributes], "fqdn=#{host_params[:name]}")
        # Using except because keep param prevents deleting
        my_params = host_params.except(:host_parameters_attributes).merge(lookup_values)
        @host = Host.new(my_params)
        @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        forward_request_url
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", "Update a host."
      param :id, :identifier, :required => true
      param :host, Hash, :required => true do
        param :name, String
        param :environment_id, String
        param :ip, String, :desc => "IPv4 address, not required if using a subnet with dhcp proxy"
        param :ip6, String, :desc => "IPv6 address"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
        param :operatingsystem_id, String
        param :puppetclass_ids, Array
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number, :desc => "IPv4 subnet"
        param :subnet6_id, :number, :desc => "IPv6 subnet"
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
        lookup_values = turn_params_to_values(host_params[:host_parameters_attributes], "fqdn=#{host_params[:name]}")
        # Using except because keep param prevents deleting
        process_response @host.update_attributes(host_params.except(:host_parameters_attributes).merge(lookup_values))
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
        Foreman::Deprecation.api_deprecation_warning('The /status route is deprecated, please use the new /status/configuration instead')
        render :json => { :status => @host.get_status(HostStatus::ConfigurationStatus).to_label }.to_json if @host
      end

      private

      def resource_class
        Host::Managed
      end

      # this is required for template generation (such as pxelinux) which is not done via a web request
      def forward_request_url
        @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
      end
    end
  end
end
