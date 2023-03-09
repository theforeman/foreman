require 'webpack-rails'
module ReactjsHelper
  # Mount react component in views
  # Params:
  # +name+:: the component name from the componentRegistry
  # +props+:: props to pass to the component
  #          valid value types: Hash, json-string, nil
  def react_component(name, props = {})
    props = props.to_json if props.is_a?(Hash)

    content_tag('foreman-react-component', '', :name => name, :data => { props: props })
  end

  def webpack_root_url(plugin)
    "/assets/#{plugin.name}"
  end

  def load_plugin_module_script(plugin, prefix = nil)
    # This should match webpack.config.js entries for plugin's federated module entry point.
    entry_point = [prefix, 'index'].compact.join('_')
    "window.tfm.tools.loadPluginModule(url: ""#{webpack_root_url(plugin)}"", scope: ""#{plugin.name}"", module: ""./#{entry_point}"");"
  end

  def webpacked_plugins_with_global_css
    javascript_include_tag('foreman-vendor')
    global_css_tags(global_plugins_list).join.html_safe
  end

  def webpacked_plugins_js_for(*plugin_names)
    js_tags_for(select_requested_plugins(plugin_names)).join.html_safe
  end

  def webpacked_plugins_with_global_js
    global_js_tags(global_plugins_list).join.html_safe
  end

  def webpacked_plugins_css_for(*plugin_names)
    # No need to load CSS separately, since it should be referenced from the corresponding JS file.

    # css_tags_for(select_requested_plugins(plugin_names)).join.html_safe
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
    javascript_tag do
      requested_plugins.map do |plugin|
        load_plugin_module_script(plugin)
      end.join("\n")
    end
  end

  def global_js_tags(requested_plugins)
    javascript_tag(defer: 'defer') do
      requested_plugins.map do |plugin|
        plugin[:files].map do |file|
          load_plugin_module_script(plugin, file)
        end.join("\n")
      end.join("\n")
    end
  end

  def global_css_tags(requested_plugins)
    # No need to load CSS separately, since it should be referenced from the corresponding JS file.

    # requested_plugins.map do |plugin|
    #   plugin[:files].map do |file|
    #     stylesheet_link_tag(*webpack_asset_paths("#{plugin[:id]}:#{file}", :extension => 'css'))
    #   end
    # end
  end

  def css_tags_for(requested_plugins)
    # No need to load CSS separately, since it should be referenced from the corresponding JS file.

    # requested_plugins.map do |plugin|
    #   stylesheet_link_tag(*webpack_asset_paths(plugin.to_s, :extension => 'css'))
    # end
  end

  private

  def global_plugins_list
    Foreman::Plugin.with_global_js.map { |plugin| { id: plugin.id, files: plugin.global_js_files } }
  end
end
