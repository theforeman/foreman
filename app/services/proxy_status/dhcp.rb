module ProxyStatus
  class DHCP < Base
    def subnets
      fetch_proxy_data do
        @subnets = api.subnets.map do |s|
          Net::DHCP::Subnet.new s
        end.compact
      end
    end

    def subnet(dhcp_subnet)
      fetch_proxy_data "details" do
        result = api.subnet dhcp_subnet[:network]
        net = Net::DHCP::Subnet.new result.merge!(dhcp_subnet)
        net.reservations.each { |res| res['network'] = net.network }
        net
      end
    end

    def self.humanized_name
      'DHCP'
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::DHCP)
