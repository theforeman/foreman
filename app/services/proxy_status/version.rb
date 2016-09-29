module ProxyStatus
  class Version < Base
    def versions
      fetch_proxy_data do
        api.proxy_versions
      end
    end

    def self.humanized_name
      'Version'
    end

    alias_method :version, :versions
  end
end
ProxyStatus.status_registry.add(ProxyStatus::Version)
