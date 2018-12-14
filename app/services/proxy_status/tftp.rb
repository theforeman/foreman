module ProxyStatus
  class TFTP < Base
    def server
      proxy.setting('TFTP', 'tftp_servername') || fetch_proxy_data { api.bootServer }
    end

    def self.humanized_name
      'TFTP'
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::TFTP)
