module ProxyStatus
  class Puppet < Base
    def environment_stats
      fetch_proxy_data do
        api.environment_details.inject({}) do |all, current|
          all.update(current.first => all[current.first].nil? ? '?' : current.last[:class_count])
        end
      end
    end

    def self.humanized_name
      'Puppet'
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::Puppet)
