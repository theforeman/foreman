module ProxyStatus
  class DHCP < Base

    def subnets
      return @subnets if @subnets

      fetch_proxy_data do
        @subnets = api.subnets.map do |subnet|
          records = api.subnet(subnet['network'])
          Net::DHCP::Subnet.new subnet.merge(records)
        end
      end
    end

    def self.humanized_name
      'DHCP'
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::DHCP)
