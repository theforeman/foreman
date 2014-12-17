module Api
  module V2
    class SubnetsController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/subnets', N_("List of subnets")
      api :GET, "/domains/:domain_id/subnets", N_("List of subnets for a domain")
      api :GET, "/locations/:location_id/subnets", N_("List of subnets per location")
      api :GET, "/organizations/:organization_id/subnets", N_("List of subnets per organization")
      param :domain_id, String, :desc => N_("ID of domain")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @subnets = resource_scope_for_index.includes(:tftp, :dhcp, :dns)
      end

      api :GET, "/subnets/:id/", N_("Show a subnet")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :subnet do
        param :subnet, Hash, :required => true, :action_aware => true do
          param :name, String, :desc => N_("Subnet name"), :required => true
          param :network, String, :desc => N_("Subnet network"), :required => true
          param :mask, String, :desc => N_("Netmask for this subnet"), :required => true
          param :gateway, String, :desc => N_("Primary DNS for this subnet")
          param :dns_primary, String, :desc => N_("Primary DNS for this subnet")
          param :dns_secondary, String, :desc => N_("Secondary DNS for this subnet")
          param :ipam, String, :desc => N_('IP Address auto suggestion mode for this subnet, valid values are "DHCP", "Internal DB", "None"')
          param :from, String, :desc => N_("Starting IP Address for IP auto suggestion")
          param :to, String, :desc => N_("Ending IP Address for IP auto suggestion")
          param :vlanid, String, :desc => N_("VLAN ID for this subnet")
          param :domain_ids, Array, :desc => N_("Domains in which this subnet is part")
          param :dhcp_id, :number, :desc => N_("DHCP Proxy to use within this subnet")
          param :tftp_id, :number, :desc => N_("TFTP Proxy to use within this subnet")
          param :dns_id, :number, :desc => N_("DNS Proxy to use within this subnet")
          param :boot_mode, String, :desc => N_('Default boot mode for interfaces assigned to this subnet, valid values are "Static", "DHCP"')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/subnets', N_("Create a subnet")
      param_group :subnet, :as => :create

      def create
        @subnet = Subnet.new(foreman_params)
        process_response @subnet.save
      end

      api :PUT, '/subnets/:id', N_("Update a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true
      param_group :subnet

      def update
        process_response @subnet.update_attributes(foreman_params)
      end

      api :DELETE, '/subnets/:id', N_("Delete a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true

      def destroy
        process_response @subnet.destroy
      end

      private

      def allowed_nested_id
        %w(domain_id location_id organization_id)
      end
    end
  end
end
