class Subnet < Apipie::Client::CliCommand

  desc 'index', 'List of subnets'
  method_option :search, :required => false, :desc => 'Filter results', :type => :string
  method_option :order, :required => false, :desc => 'Sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'create', 'Create a subnet'
  method_option :name, :required => true, :desc => 'Subnet name', :type => :string
  method_option :network, :required => true, :desc => 'Subnet network', :type => :string
  method_option :mask, :required => true, :desc => 'Netmask for this subnet', :type => :string
  method_option :gateway, :required => false, :desc => 'Primary DNS for this subnet', :type => :string
  method_option :dns_primary, :required => false, :desc => 'Primary DNS for this subnet', :type => :string
  method_option :dns_secondary, :required => false, :desc => 'Secondary DNS for this subnet', :type => :string
  method_option :from, :required => false, :desc => 'Starting IP Address for IP auto suggestion', :type => :string
  method_option :to, :required => false, :desc => 'Ending IP Address for IP auto suggestion', :type => :string
  method_option :vlanid, :required => false, :desc => 'VLAN ID for this subnet', :type => :string
  method_option :domain_ids, :required => false, :desc => 'Domains in which this subnet is part', :type => :string
  method_option :dhcp_id, :required => false, :desc => 'DHCP Proxy to use within this subnet', :type => :string
  method_option :tftp_id, :required => false, :desc => 'TFTP Proxy to use within this subnet', :type => :string
  method_option :dns_id, :required => false, :desc => 'DNS Proxy to use within this subnet', :type => :string
  def create
    params = transform_options([], {"subnet"=>["name", "network", "mask", "gateway", "dns_primary", "dns_secondary", "from", "to", "vlanid", "domain_ids", "dhcp_id", "tftp_id", "dns_id"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a subnet'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => 'Subnet numeric identifier', :type => :string
  method_option :name, :required => true, :desc => 'Subnet name', :type => :string
  method_option :network, :required => true, :desc => 'Subnet network', :type => :string
  method_option :mask, :required => true, :desc => 'Netmask for this subnet', :type => :string
  method_option :gateway, :required => false, :desc => 'Primary DNS for this subnet', :type => :string
  method_option :dns_primary, :required => false, :desc => 'Primary DNS for this subnet', :type => :string
  method_option :dns_secondary, :required => false, :desc => 'Secondary DNS for this subnet', :type => :string
  method_option :from, :required => false, :desc => 'Starting IP Address for IP auto suggestion', :type => :string
  method_option :to, :required => false, :desc => 'Ending IP Address for IP auto suggestion', :type => :string
  method_option :vlanid, :required => false, :desc => 'VLAN ID for this subnet', :type => :string
  method_option :domain_ids, :required => false, :desc => 'Domains in which this subnet is part', :type => :string
  method_option :dhcp_id, :required => false, :desc => 'DHCP Proxy to use within this subnet', :type => :string
  method_option :tftp_id, :required => false, :desc => 'TFTP Proxy to use within this subnet', :type => :string
  method_option :dns_id, :required => false, :desc => 'DNS Proxy to use within this subnet', :type => :string
  def update
    params = transform_options(["id"], {"subnet"=>["name", "network", "mask", "gateway", "dns_primary", "dns_secondary", "from", "to", "vlanid", "domain_ids", "dhcp_id", "tftp_id", "dns_id"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a subnet'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => 'Subnet numeric identifier', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

  desc 'freeip', 'Query subnet DHCP proxy for an unused IP'
  method_option :subnet_id, :required => false, :desc => '', :type => :string
  method_option :host_mac, :required => false, :desc => '', :type => :string
  def freeip
    params = transform_options([])
    data, resp = client.freeip(params)
    print_data(data)
  end

end
