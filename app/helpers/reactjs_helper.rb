module ReactjsHelper
  def mount_react_component(name, selector, data = [], opts = {})
    Foreman::Deprecation.deprecation_warning('2.5', 'use #react_component instead of #mount_react_component')
    javascript_tag defer: 'defer' do
      "$(tfm.reactMounter.mount('#{name}', '#{selector}', #{data}, #{opts[:flatten_data] || false}));".html_safe
    end
  end

  # Mount react component in views
  # Params:
  # +name+:: the component name from the componentRegistry
  # +props+:: props to pass to the component
  #          valid value types: Hash, json-string, nil
  def react_component(name, props = {})
    props = props.to_json if props.is_a?(Hash)

    content_tag('foreman-react-component', '', :name => name, :data => { props: props })
  end

  def webpacked_plugins_js_for(*plugin_names)
    js_tags_for(select_requested_plugins(plugin_names)).join.html_safe
  end

  def webpacked_plugins_with_global_js
    js_tags_for_global_files(Foreman::Plugin.with_global_js.map { |plugin| { id: plugin.id, files: plugin.global_js_files } }).join.html_safe
  end

  def webpacked_plugins_css_for(*plugin_names)
    css_tags_for(select_requested_plugins(plugin_names)).join.html_safe
  end

  def select_requested_plugins(plugin_names)
    available_plugins = Foreman::Plugin.with_webpack.map(&:id)
    missing_plugins = plugin_names - available_plugins
    if missing_plugins.any?
      logger.error { "Failed to include webpack assets for plugins: #{missing_plugins}" }
      raise ::Foreman::Exception.new("Failed to include webpack assets for plugins: #{missing_plugins}") if Rails.env.development?
    end
    plugin_names & available_plugins
  end

  def js_tags_for(requested_plugins)
    requested_plugins.map do |plugin|
      javascript_include_tag(*webpack_asset_paths(plugin.to_s, :extension => 'js'))
    end
  end

  def js_tags_for_global_files(requested_plugins)
    requested_plugins.map do |plugin|
      plugin[:files].map do |file|
        javascript_include_tag(*webpack_asset_paths(plugin[:id].to_s + ":#{file}", :extension => 'js'), :defer => "defer")
      end
    end
  end

  def css_tags_for(requested_plugins)
    requested_plugins.map do |plugin|
      stylesheet_link_tag(*webpack_asset_paths(plugin.to_s, :extension => 'css'))
    end
  end
end
