module Api
  module V2
    class SubnetsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Subnet
      include ParameterAttributes

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy freeip}
      before_action :find_ipam, :only => %w{freeip}
      before_action :process_parameter_attributes, :only => %w{update}

      api :GET, '/subnets', N_("List of subnets")
      api :GET, "/domains/:domain_id/subnets", N_("List of subnets for a domain")
      api :GET, "/locations/:location_id/subnets", N_("List of subnets per location")
      api :GET, "/organizations/:organization_id/subnets", N_("List of subnets per organization")
      param :domain_id, String, :desc => N_("ID of domain")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Subnet)

      def index
        @subnets = resource_scope_for_index.includes(:tftp, :dhcp, :dns)
        @subnets = @subnets.network_reorder(params[:order]) if params[:order].present? && params[:order] =~ /\Anetwork( ASC| DESC)?\Z/
      end

      api :GET, "/subnets/:id/", N_("Show a subnet")
      param :id, :identifier, :required => true
      param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")

      def show
      end

      def_param_group :subnet do
        param :subnet, Hash, :required => true, :action_aware => true do
          param :name, String, :desc => N_("Subnet name"), :required => true
          param :description, String, :desc => N_("Subnet description")
          param :network_type, Subnet::SUBNET_TYPES.values, :desc => N_('Type or protocol, IPv4 or IPv6, defaults to IPv4')
          param :network, String, :desc => N_("Subnet network"), :required => true
          param :cidr, String, :desc => N_("Network prefix in CIDR notation")
          param :mask, String, :desc => N_("Netmask for this subnet")
          param :gateway, String, :desc => N_("Subnet gateway")
          param :dns_primary, String, :desc => N_("Primary DNS for this subnet")
          param :dns_secondary, String, :desc => N_("Secondary DNS for this subnet")
          param :ipam, IPAM::MODES.values, :desc => N_('IP Address auto suggestion mode for this subnet.')
          param :from, String, :desc => N_("Starting IP Address for IP auto suggestion")
          param :to, String, :desc => N_("Ending IP Address for IP auto suggestion")
          param :vlanid, String, :desc => N_("VLAN ID for this subnet")
          param :mtu, Integer, :desc => N_("MTU for this subnet")
          param :domain_ids, Array, :desc => N_("Domains in which this subnet is part")
          Subnet.registered_smart_proxies.each do |name, options|
            param :"#{name}_id", :number, :desc => options[:api_description]
          end
          param :boot_mode, Subnet::BOOT_MODES.values, :desc => N_('Default boot mode for interfaces assigned to this subnet.')
          param :subnet_parameters_attributes, Array, :required => false, :desc => N_("Array of parameters (name, value)")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/subnets', N_("Create a subnet")
      param_group :subnet, :as => :create

      def create
        @subnet = Subnet.new_network_type(subnet_params)
        process_response @subnet.save
      end

      api :PUT, '/subnets/:id', N_("Update a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true
      param_group :subnet

      def update
        process_response @subnet.update(subnet_params)
      end

      api :DELETE, '/subnets/:id', N_("Delete a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true

      def destroy
        process_response @subnet.destroy
      end

      api :GET, "/subnets/:id/freeip", N_("Provides an unused IP address in this subnet")
      param :id, :identifier, :required => true
      param :mac, String, :desc => N_("MAC address to reuse the IP for this host")
      param :excluded_ips, Array, :desc => N_("IP addresses that should be excluded from suggestion")

      def freeip
      end

      private

      def find_ipam
        @ipam = @subnet.unused_ip(params[:mac], params[:excluded_ips] || [])
      end

      def action_permission
        case params[:action]
        when 'freeip'
          :view
        else
          super
        end
      end

      def allowed_nested_id
        %w(domain_id location_id organization_id)
      end
    end
  end
end
