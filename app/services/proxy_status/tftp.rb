module ProxyStatus
  class TFTP < Base
    def server
      fetch_proxy_data do
        api.bootServer
      end
    end

    def self.humanized_name
      'TFTP'
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::TFTP)
