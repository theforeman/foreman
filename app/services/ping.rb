class Ping
  class << self
    def ping
      {
        'foreman': {
          database: ping_database
        }
      }.merge(plugins_ping)
    end

    def statuses
      {
        'foreman': {
          version: SETTINGS[:version].full,
          api: {
            version: Apipie.configuration.default_version
          },
          plugins: Foreman::Plugin.all,
          smart_proxies: statuses_smart_proxies,
          compute_resources: statuses_compute_resources
        }
      }.merge(plugins_statuses).merge(ping) do |_key, old_val, new_val|
        old_val.merge(new_val)
      end
    end

    private

    def ping_database
      ActiveRecord::Base.connection.active?
    end

    def statuses_compute_resources
      results = []
      ComputeResource.all.index.map do |resource|
        errors = resource.ping
        results << {
          name: resource.name,
          status: errors.empty? ? 'ok' : 'FAIL',
          errors: errors.full_messages
        }
      end
      results
    end

    def statuses_smart_proxies
      results = []
      SmartProxy.all.includes(:features).map do |proxy|
        begin
          version = proxy.statuses[:version].version['version']
          features = proxy.statuses[:version].version['modules']
          failed_features = proxy.statuses[:logs].logs.failed_modules
          status = 'ok'
        rescue ::Foreman::WrappedException => error
          version ||= 'N/A'
          features ||= {}
          failed_features ||= {}
          status = error.to_s
        end
        results << {
          name: proxy.name,
          status: status,
          version: version,
          features: features,
          failed_features: failed_features
        }
      end
      results
    end

    def plugins_ping
      Foreman::Plugin.all.inject({}) do |all, plugin|
        next all if plugin.ping_extension.nil?
        all.update({ "#{plugin.name}": plugin.ping_extension.call })
      end
    end

    def plugins_statuses
      Foreman::Plugin.all.inject({}) do |all, plugin|
        next all if plugin.status_extension.nil?
        all.update({ "#{plugin.name}": plugin.status_extension.call })
      end
    end
  end
end
