module Updates
  class Wiki < Base
    def url
      "http://projects.theforeman.org/releases.json"
    end

    def file_name
      "updates.json"
    end

    def fetch_plugin_updates
      latest_plugin_version_for_current_foreman fetch
    end

    def fetch_core_updates
      latest_core_version_for_current_foreman fetch
    end

    def latest_core_version_for_current_foreman(data)
      res = { :latest => "", :current_latest => "" }
      return res if data.empty?
      major = data['core'].keys.first
      minor = data['core'][major].keys.first
      res[:latest] = data['core'][major][minor].first
      res[:current_latest] = data['core'][SETTINGS[:version].major][SETTINGS[:version].minor].first rescue SETTINGS[:version].to_s
      res
    end

    def latest_plugin_version_for_current_foreman(data)
      Foreman::Plugin.all.map do |plugin|
        next { plugin.id.to_s => "" } if data.empty?
        if data['plugins'][plugin.id.to_s]
          latest = data["plugins"][plugin.id.to_s].select do |item, value|
            value['requires_foreman'] == plugin_short_req(plugin.foreman_req)
          end
          { plugin.id.to_s => latest.empty? ? "" : latest.first.first }
        else
          { plugin.id.to_s => "" }
        end
      end
    end

    def plugin_short_req(matcher)
      matcher.match(/ (\d+\.\d+)/)[1]
    end
  end
end

Updates.register_source(Updates::Wiki)
