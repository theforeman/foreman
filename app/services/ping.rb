class Ping
  STATUS_OK = 'ok'.freeze
  STATUS_FAIL = 'FAIL'.freeze

  class << self
    def ping
      {
        'foreman': {
          database: ping_database,
        },
      }.merge(plugins_ping)
    end

    def statuses
      plugins = Foreman::Plugin.all.map do |plugin|
        {
          name: plugin.id.to_s,
          version: plugin.version,
        }
      end
      {
        'foreman': {
          version: SETTINGS[:version].full,
          api: {
            version: Apipie.configuration.default_version,
          },
          plugins: plugins,
          smart_proxies: statuses_smart_proxies,
          compute_resources: statuses_compute_resources,
        },
      }.merge(plugins_statuses).merge(ping) do |_key, old_val, new_val|
        old_val.merge(new_val)
      end
    end

    private

    def duration_ms(start)
      ((Time.new - start) * 1000).round.to_s
    end

    def ping_database
      start = Time.now
      {
        active: ActiveRecord::Base.connection.active?,
        duration_ms: duration_ms(start),
      }
    end

    def statuses_compute_resources
      results = []
      ComputeResource.all.index.map do |resource|
        start = Time.now
        errors = resource.ping
        results << {
          name: resource.name,
          status: errors.empty? ? STATUS_OK : STATUS_FAIL,
          duration_ms: duration_ms(start),
          errors: errors.full_messages,
        }
      end
      results
    end

    def statuses_smart_proxies
      results = []
      SmartProxy.all.includes(:features).map do |proxy|
        start = Time.now
        begin
          version = proxy.statuses[:version].version['version']
          features = proxy.statuses[:version].version['modules']
          failed_features = ProxyAPI::V2::Features.new(:url => proxy.url).features.select { |f, p| p['state'] == 'failed' }
          status = STATUS_OK
        rescue ::Foreman::WrappedException => error
          version ||= 'N/A'
          features ||= {}
          failed_features ||= {}
          status = error.to_s
        end
        results << {
          name: proxy.name,
          status: status,
          duration_ms: duration_ms(start),
          version: version,
          features: features,
          failed_features: failed_features,
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
