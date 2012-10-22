module Api
  module V1
    class SubnetsController < V1::BaseController

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/subnets', 'List of subnets'
      param :search, String, :desc => 'Filter results'
      param :order, String, :desc => 'Sort results'
      def index
        @subnets = Subnet.search_for(params[:search], :order => params[:order])
      end

      api :POST, '/subnets', 'Create a subnet'
      param :subnet, Hash, :required => true do
        param :name, String, :desc => 'Subnet name', :required => true
        param :network, String, :desc => 'Subnet network', :required => true
        param :mask, String, :desc => 'Netmask for this subnet', :required => true
        param :gateway, String, :allow_nil => true, :desc => 'Primary DNS for this subnet'
        param :dns_primary, String, :allow_nil => true, :desc => 'Primary DNS for this subnet'
        param :dns_secondary, String, :allow_nil => true, :desc => 'Secondary DNS for this subnet'
        param :from, String, :allow_nil => true, :desc => 'Starting IP Address for IP auto suggestion'
        param :to, String, :allow_nil => true, :desc => 'Ending IP Address for IP auto suggestion'
        param :vlanid, String, :allow_nil => true, :desc => 'VLAN ID for this subnet'
        param :domain_ids, Array, :allow_nil => true, :desc => 'Domains in which this subnet is part'
        param :dhcp_id, :number, :allow_nil => true, :desc => 'DHCP Proxy to use within this subnet'
        param :tftp_id, :number, :allow_nil => true, :desc => 'TFTP Proxy to use within this subnet'
        param :dns_id, :number, :allow_nil => true, :desc => 'DNS Proxy to use within this subnet'
      end
      def create
        @subnet = Subnet.new(params[:subnet])
        process_response @subnet.save
      end

      api :PUT, '/subnets/:id', 'Update a subnet'
      param :id, String, :desc => 'Subnet numeric identifier', :required => true
      param :subnet, Hash, :required => true do
        param :name, String, :allow_nil => true, :desc => 'Subnet name'
        param :network, String, :allow_nil => true, :desc => 'Subnet network'
        param :mask, String, :allow_nil => true, :desc => 'Netmask for this subnet'
        param :gateway, String, :allow_nil => true, :desc => 'Primary DNS for this subnet'
        param :dns_primary, String, :allow_nil => true, :desc => 'Primary DNS for this subnet'
        param :dns_secondary, String, :allow_nil => true, :desc => 'Secondary DNS for this subnet'
        param :from, String, :allow_nil => true, :desc => 'Starting IP Address for IP auto suggestion'
        param :to, String, :allow_nil => true, :desc => ' Ending IP Address for IP auto suggestion'
        param :vlanid, String, :allow_nil => true, :desc => 'VLAN ID for this subnet'
        param :domain_ids, Array, :allow_nil => true, :desc => 'Domains in which this subnet is part'
        param :dhcp_id, :number, :allow_nil => true, :desc => 'DHCP Proxy to use within this subnet'
        param :tftp_id, :number, :allow_nil => true, :desc => 'TFTP Proxy to use within this subnet'
        param :dns_id, :number, :allow_nil => true, :desc => 'DNS Proxy to use within this subnet'
      end
      def update
        process_response @subnet.update_attributes(params[:subnet])
      end

      api :DELETE, '/subnets/:id', 'Delete a subnet'
      param :id, String, :desc => 'Subnet numeric identifier', :required => true
      def destroy
        process_response @subnet.destroy
      end

      api :POST, '/subnets/freeip', 'Query subnet DHCP proxy for an unused IP'
      param :subnet_id, :number
      param :host_mac, String
      def freeip
        subnet= Subnet.find(params[:subnet_id])

        if (ip = subnet.unused_ip(params[:host_mac]))
          render :json => {:ip => ip}
        else
          # we don't want any failures if we failed to query our proxy
          head :status => 200
        end
      rescue => e
        logger.warn "Failed to query #{subnet} for free ip: #{e}"
        head :status => 500
      end

    end
  end
end
