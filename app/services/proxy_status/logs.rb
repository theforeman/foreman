module ProxyStatus
  class Logs < Base
    def logs
      fetch_proxy_data do
        ::SmartProxies::LogBuffer.new(api.all(proxy.expired_logs.to_i || 0))
      end
    end

    def self.humanized_name
      'Logs'
    end

    protected

    def api_class
      ProxyAPI::Logs
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::Logs)
