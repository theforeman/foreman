module Api
  module V2
    class SubnetsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/subnets', N_("List of subnets")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @subnets = Subnet.
          authorized(:view_subnets).
          includes(:tftp, :dhcp, :dns).
          search_for(*search_options).paginate(paginate_options)
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
        end
      end

      api :POST, '/subnets', N_("Create a subnet")
      param_group :subnet, :as => :create

      def create
        @subnet = Subnet.new(params[:subnet])
        process_response @subnet.save
      end

      api :PUT, '/subnets/:id', N_("Update a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true
      param_group :subnet

      def update
        process_response @subnet.update_attributes(params[:subnet])
      end

      api :DELETE, '/subnets/:id', N_("Delete a subnet")
      param :id, :number, :desc => N_("Subnet numeric identifier"), :required => true

      def destroy
        process_response @subnet.destroy
      end

    end
  end
end
