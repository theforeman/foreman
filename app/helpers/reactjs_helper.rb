module ReactjsHelper
  def mount_react_component(name, selector, data = [])
    javascript_tag defer: 'defer' do
      "$(tfm.reactMounter.mount('#{name}', '#{selector}', #{data}));".html_safe
    end
  end

  def webpacked_plugins_js_for(*plugin_names)
    tags = create_tags(plugin_names)
    return nil if tags.empty?
    tags.inject(&:concat).html_safe
  end

  def create_tags(plugin_names)
    js_tags_for select_requested_plugins(all_webpacked_plugins.map(&:id), plugin_names)
  end

  def select_requested_plugins(webpacked_plugin_ids, plugin_names)
    plugin_names.select { |plugin_name| webpacked_plugin_ids.include?(plugin_name) }
  end

  def all_webpacked_plugins
    Foreman::Plugin.registered_plugins.values.select do |plugin|
      File.exist? File.join(plugin.path, 'webpack/index.js')
    end
  end

  def js_tags_for(requested_plugins)
    requested_plugins.map do |plugin|
      javascript_include_tag(*webpack_asset_paths(plugin, :extension => 'js'), "data-turbolinks-track" => true)
    end
  end
end
