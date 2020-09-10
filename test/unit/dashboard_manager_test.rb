require 'test_helper'

class DashboardManagerTest < ActiveSupport::TestCase
  test '.add_widget_to_user adds built-in widget with params' do
    user = FactoryBot.create(:user)
    user.widgets.clear

    widget_params = {template: 'status_widget', sizex: 8, sizey: 1, name: 'Host Configuration Status'}
    Dashboard::Manager.add_widget_to_user(user, widget_params)

    assert_equal 1, user.widgets.size
    assert_equal widget_params.stringify_keys, user.widgets.first.attributes.slice(*widget_params.stringify_keys.keys)
  end

  test '.add_widget_to_user adds plugin widget with params' do
    user = FactoryBot.create(:user)
    user.widgets.clear

    widget_params = {template: 'plugin_widget', sizex: 8, sizey: 1, name: 'Plugin 1'}
    Foreman::Plugin.expects(:all).returns([mock(dashboard_widgets: [{name: 'Plugin 1', template: 'plugin_widget'}])])
    Dashboard::Manager.add_widget_to_user(user, widget_params)

    assert_equal 1, user.widgets.size
    assert_equal widget_params.stringify_keys, user.widgets.first.attributes.slice(*widget_params.stringify_keys.keys)
  end

  test '.add_widget_to_user raises exception for unknown template' do
    widget_params = {template: 'unknown_template', sizex: 8, sizey: 1, name: 'Host Configuration Status'}
    e = assert_raises(Foreman::Exception) { Dashboard::Manager.add_widget_to_user(mock('user'), widget_params) }
    assert_includes e.message, 'Unallowed template for dashboard widget: unknown_template'
  end

  test '.default_widgets returns built-in widgets' do
    Dashboard::Manager.stubs(:registered_report_orgins).returns(['Puppet'])
    Foreman::Plugin.expects(:all).returns([])
    assert_equal 8, Dashboard::Manager.default_widgets.count
  end

  test '.default_widgets adds plugin widgets' do
    Foreman::Plugin.expects(:all).returns([mock(dashboard_widgets: [:plugin1]), mock(dashboard_widgets: [:plugin2, :plugin3])])
    Dashboard::Manager.expects(:builtin_widgets).returns([:builtin1, :builtin2])
    widgets = Dashboard::Manager.default_widgets
    assert_equal 5, widgets.count
    assert_includes widgets, :plugin1
    assert_includes widgets, :plugin2
    assert_includes widgets, :plugin3
  end

  test '.find_default_widget_by_name returns built-in widget' do
    assert_equal ['status_chart_widget'], Dashboard::Manager.find_default_widget_by_name('Host Configuration Chart for All').map { |w| w[:template] }
  end

  test '.find_default_widget_by_name returns plugin widget' do
    Foreman::Plugin.expects(:all).returns([mock(dashboard_widgets: [{name: 'Plugin 1', template: 'plugin1'}])])
    assert_equal ['plugin1'], Dashboard::Manager.find_default_widget_by_name('Plugin 1').map { |w| w[:template] }
  end

  test '.find_default_widget_by_name returns empty array for unknown widget' do
    assert_equal [], Dashboard::Manager.find_default_widget_by_name('Unknown')
  end

  test '.reset_user_to_default removes and adds default widgets' do
    user = FactoryBot.create(:user)
    user.widgets = [user.widgets.first]

    Foreman::Plugin.expects(:all).at_least_once.returns([])
    Dashboard::Manager.reset_user_to_default(user)
    user.widgets.reload
    assert_equal Dashboard::Manager.default_widgets.count,
      user.widgets.count
  end
end
