require 'test_helper'

class ReactjsHelperTest < ActionView::TestCase
  include ReactjsHelper

  def webpack_asset_paths(bundle_name, opts)
    ["<script src=\"https://foreman.example.com:3808/webpack/#{bundle_name}.js\"></script>"]
  end

  setup do
    Foreman::Plugin.register(:foreman_react) {}
    Foreman::Plugin.register(:foreman_angular) {}
    Foreman::Plugin.any_instance.stubs(:uses_webpack?).returns(true)
  end

  teardown do
    Foreman::Plugin.unregister(:foreman_react)
    Foreman::Plugin.unregister(:foreman_angular)
  end

  test "should select requested plugins" do
    plugin_names = [:foreman_react, :foreman_backbone]
    selected_plugins = select_requested_plugins(plugin_names)
    assert selected_plugins.include?(:foreman_react)
    assert_equal 1, selected_plugins.size
  end

  test "should create js tags" do
    tags = js_tags_for [:foreman_react, :foreman_angular]
    assert_equal 2, tags.size
  end

  test "should not create js for plugins without webpacked js" do
    assert_empty webpacked_plugins_js_for(:foreman_meteor)
  end

  test "should create js for plugins with webpacked js" do
    res = webpacked_plugins_js_for(:foreman_react, :foreman_angular)
    assert res.include?('webpack/foreman_react.js')
    assert res.include?('webpack/foreman_angular.js')
  end

  test "should be able to load global js in foreman core" do
    Foreman::Plugin.register :plugin_with_global_js do
      register_global_js_file 'some_global_file'
    end

    res = webpacked_plugins_with_global_js
    assert res.include?('webpack/plugin_with_global_js:some_global_file.js')
  end
end
