require 'test_helper'

class ReactjsHelperTest < ActionView::TestCase
  include ReactjsHelper

  def javascript_pack_tag(bundle_name, opts)
    "<script src=\"https://foreman.example.com/public/packs/#{bundle_name}.js\"></script>"
  end

  setup do
    Foreman::Plugin.register(:foreman_react) {}
    Foreman::Plugin.register(:foreman_angular) {}
    @plugins = [Foreman::Plugin.find(:foreman_react), Foreman::Plugin.find(:foreman_angular)]
    self.stubs(:all_webpacked_plugins).returns(@plugins)
  end

  test "should select requested plugins" do
    plugin_names = [:foreman_react, :foreman_backbone]
    selected_plugins = select_requested_plugins(all_webpacked_plugins.map(&:id), plugin_names)
    assert selected_plugins.include?(:foreman_react)
    assert_equal 1, selected_plugins.size
  end

  test "should create js tags" do
    tags = js_tags_for [:foreman_react, :foreman_angular]
    assert_equal 2, tags.size
  end

  test "should not create js for plugins without webpacked js" do
    refute webpacked_plugins_js_for(:foreman_meteor)
  end

  test "should create js for plugins with webpacked js" do
    res = webpacked_plugins_js_for(:foreman_react, :foreman_angular)
    assert res.include?('webpack/react.js')
    assert res.include?('webpack/angular.js')
  end
end
