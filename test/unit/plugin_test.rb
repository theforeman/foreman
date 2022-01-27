# Redmine - project management software
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'test_helper'
require 'pagelets_test_helper'

module Awesome
  module Provider; class MyAwesome < ::ComputeResource; end; end
  def self.register_smart_proxy(name, options = {})
  end
end
module Awesome; class FakeFacet; end; end

module Test
  class Resource
  end
end

class PluginTest < ActiveSupport::TestCase
  module MyMod
    def my_helper
      'my_helper'
    end

    private

    def private_helper
      'private_helper'
    end
  end

  setup :clear_plugins

  def test_register
    Foreman::Plugin.register :foo do
      name 'Foo plugin'
      url 'http://example.net/plugins/foo'
      author 'John Smith'
      author_url 'http://example.net/jsmith'
      description 'This is a test plugin'
      version '0.0.1'
      path '/some/path/on/disk'
    end

    assert_equal 1, Foreman::Plugin.all.size

    plugin = Foreman::Plugin.find('foo')
    assert plugin.is_a?(Foreman::Plugin)
    assert_equal :foo, plugin.id
    assert_equal 'Foo plugin', plugin.name
    assert_equal 'http://example.net/plugins/foo', plugin.url
    assert_equal 'John Smith', plugin.author
    assert_equal 'http://example.net/jsmith', plugin.author_url
    assert_equal 'This is a test plugin', plugin.description
    assert_equal '0.0.1', plugin.version
    assert_equal '/some/path/on/disk', plugin.path
  end

  def test_installed
    Foreman::Plugin.register(:foo) {}
    assert_equal true, Foreman::Plugin.installed?(:foo)
    assert_equal false, Foreman::Plugin.installed?(:bar)
  end

  def test_menu
    url_hash = {:controller => 'hosts', :action => 'index'}
    assert_difference 'Menu::Manager.items(:project_menu).size' do
      Foreman::Plugin.register :foo do
        menu :project_menu, :foo_menu_item, :url_hash => url_hash, :caption => 'Foo'
      end
    end
    menu_item = Menu::Manager.items(:project_menu).detect { |i| i.name == :foo_menu_item }
    assert_not_nil menu_item
    assert_equal 'Foo', menu_item.caption
    assert_equal url_hash, menu_item.url_hash
  end

  def test_delete_menu_item
    Menu::Manager.map(:project_menu).item(:foo_menu_item, :caption => 'Foo')
    assert_difference 'Menu::Manager.items(:project_menu).size', -1 do
      Foreman::Plugin.register :foo do
        delete_menu_item :project_menu, :foo_menu_item
      end
    end
    assert_nil Menu::Manager.items(:project_menu).detect { |i| i.name == :foo_menu_item }
  end

  def test_requires_foreman_2_part
    plugin = Foreman::Plugin.register(:foo) {}
    SETTINGS[:version].stubs(:notag).returns('2.1')

    # Specific version without hash
    assert plugin.requires_foreman('= 2.1')
    assert plugin.requires_foreman('~> 2.1')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('2.2')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('3')
    end

    # Specific version
    assert plugin.requires_foreman('= 2.1')
    assert plugin.requires_foreman('~> 2.1')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 2.2')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 2.0')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 3')
    end

    # Version or higher
    assert plugin.requires_foreman('>= 0.1')
    assert plugin.requires_foreman('>= 2.1')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('>= 2.2')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('>= 3')
    end
  end

  def test_requires_foreman_3_part
    plugin = Foreman::Plugin.register(:foo) {}
    SETTINGS[:version].stubs(:notag).returns('2.1.3')

    # Specific version without hash
    assert plugin.requires_foreman('= 2.1.3')
    assert plugin.requires_foreman('~> 2.1.0')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('2.1.4')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('2.2')
    end

    # Specific version
    assert plugin.requires_foreman('= 2.1.3')
    assert plugin.requires_foreman('~> 2.1')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 2.2.0')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 2.1.4')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('= 2.2')
    end

    # Version or higher
    assert plugin.requires_foreman('>= 0.1.0')
    assert plugin.requires_foreman('>= 2.1.3')
    assert plugin.requires_foreman('>= 2.1')
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('>= 2.2.0')
    end
    assert_raise Foreman::PluginRequirementError do
      plugin.requires_foreman('>= 2.2')
    end
  end

  def test_requires_foreman_plugin
    test = self
    other_version = '0.5.0'
    Foreman::Plugin.register :other do
      name 'Other'
      version other_version
    end
    other_version_pre = '0.5.0.pre.master'
    Foreman::Plugin.register :other_pre do
      name 'Other'
      version other_version_pre
    end
    Foreman::Plugin.register :foo do
      test.assert requires_foreman_plugin(:other, '>= 0.1.0')
      test.assert requires_foreman_plugin(:other, other_version)
      test.assert_raise Foreman::PluginRequirementError do
        requires_foreman_plugin(:other, '>= 99.0.0')
      end
      test.assert_raise Foreman::PluginRequirementError do
        requires_foreman_plugin(:other, '= 99.0.0')
      end
      test.assert_raise Foreman::PluginRequirementError do
        requires_foreman_plugin(:other_pre, '>= 0.4.0', allow_prerelease: false)
      end
      test.assert requires_foreman_plugin(:other_pre, '>= 0.4.0', allow_prerelease: true)
      test.assert requires_foreman_plugin(:other_pre, '>= 0.4.0')

      # Missing plugin
      test.assert_raise Foreman::PluginNotFound do
        requires_foreman_plugin(:missing, '>= 0.1.0')
      end
      test.assert_raise Foreman::PluginNotFound do
        requires_foreman_plugin(:missing, '0.1.0')
      end
      test.assert_raise Foreman::PluginNotFound do
        requires_foreman_plugin(:missing, '= 0.1.0')
      end
    end
  end

  def test_register_allowed_template_helpers
    Foreman::Renderer.configure { |config| config.allowed_generic_helpers -= [:my_helper] }
    refute_includes Foreman::Renderer.config.allowed_helpers, :my_helper

    Foreman::Plugin.register :foo do
      allowed_template_helpers :my_helper
    end

    # simulate application start
    Foreman::Plugin.find(:foo).to_prepare_callbacks.each(&:call)
    assert_includes Foreman::Renderer.config.allowed_helpers, :my_helper
  end

  def test_register_allowed_template_variables
    refute_includes Foreman::Renderer.config.allowed_variables, :my_variable

    Foreman::Plugin.register :foo do
      allowed_template_variables :my_variable
    end

    # simulate application start
    Foreman::Plugin.find(:foo).to_prepare_callbacks.each(&:call)
    assert_includes Foreman::Renderer.config.allowed_variables, :my_variable
  end

  def test_register_allowed_global_settings
    refute_includes Foreman::Renderer.config.allowed_global_settings, :my_global_setting

    Foreman::Plugin.register :foo do
      allowed_template_global_settings :my_global_setting
    end

    # simulate application start
    Foreman::Plugin.find(:foo).to_prepare_callbacks.each(&:call)
    assert_includes Foreman::Renderer.config.allowed_global_settings, :my_global_setting
  end

  def test_extend_rendering_helpers
    refute_includes Foreman::Renderer::Scope::Base.public_instance_methods, :my_helper
    refute_includes Foreman::Renderer::Scope::Base.public_instance_methods, :private_helper

    Foreman::Plugin.register(:foo) do
      extend_template_helpers(MyMod)
    end

    # simulate application start
    Foreman::Plugin.find(:foo).to_prepare_callbacks.each(&:call)
    assert_includes Foreman::Renderer::Scope::Base.public_instance_methods, :my_helper
    refute_includes Foreman::Renderer::Scope::Base.public_instance_methods, :private_helper
  end

  def test_add_compute_resource
    Foreman::Plugin.register :awesome_compute do
      name 'Awesome compute'
      compute_resource Awesome::Provider::MyAwesome
    end
    assert _(ComputeResource.providers.keys).must_include 'MyAwesome'
    assert _(ComputeResource.providers.values).must_include 'Awesome::Provider::MyAwesome'
    assert_equal ComputeResource.provider_class('MyAwesome'), 'Awesome::Provider::MyAwesome'
    assert _(ComputeResource.registered_providers.keys).must_include 'MyAwesome'
    assert _(ComputeResource.registered_providers.values).must_include 'Awesome::Provider::MyAwesome'
  end

  def test_invalid_compute_resource
    e = assert_raise(Foreman::Exception) do
      Foreman::Plugin.register :awesome_compute do
        name 'Awesome compute'
        compute_resource String
      end
    end
    assert_match /wrong type supplied/, e.message
  end

  def test_add_search_path_override
    plugin = Foreman::Plugin.register :filter_helpers do
      search_path_override("TestEngine") { |resource| "test_engine/another_search_path" }
    end
    assert plugin.search_overrides.key?("TestEngine")
    assert FiltersHelperOverrides.can_override?("TestEngine::TestResource")
  end

  def test_can_merge_tests_to_skip_arrays
    Foreman::Plugin.register :foo do
      tests_to_skip "FooTest" => ["test1", "test2"]
    end
    Foreman::Plugin.register :bar do
      tests_to_skip "FooTest" => ["test3", "test4"]
    end
    assert_equal ["test1", "test2", "test3", "test4"], Foreman::Plugin.tests_to_skip["FooTest"]
  end

  def test_configure_logging
    Foreman::Plugin::Logging.any_instance.expects(:configure).with(nil)
    Foreman::Plugin.register(:foo) {}

    assert Foreman::Plugin.find(:foo).logging
  end

  def test_logger
    Foreman::Plugin::Logging.any_instance.expects(:configure).with(nil)
    Foreman::Plugin.register(:foo) {}
    plugin = Foreman::Plugin.find(:foo)

    plugin.logging.expects(:add_logger).with(:test_logger, {:enabled => true})
    plugin.logger(:test_logger, {:enabled => true})
  end

  def test_register_custom_status
    status = Struct.new(:status)
    Foreman::Plugin.register :foo do
      register_custom_status(status)
    end
    # simulate application start
    Foreman::Plugin.find(:foo).to_prepare_callbacks.each(&:call)
    assert_include HostStatus.status_registry, status
    HostStatus.status_registry.delete status
  end

  def test_register_ping_extension
    foreman_ping_response = { database: { active: true, duration_ms: 0 } }
    plugin_ping_response = { service: { active: true, duration_ms: 0 } }
    Foreman::Plugin.register :foo do
      name 'foo'
      register_ping_extension { plugin_ping_response }
    end
    Ping.stubs(:ping_database).returns(foreman_ping_response[:database])
    expected_result = {
      'foreman': foreman_ping_response,
      'foo': plugin_ping_response,
    }
    assert_equal expected_result, Ping.ping
  end

  def test_register_status_extension
    foreman_database_response = { active: true, duration_ms: 0 }
    plugin_status_response = { version: '1.0.0' }
    Foreman::Plugin.register :foo do
      name 'foo'
      version '1.0.0'
      register_status_extension { plugin_status_response }
    end
    Ping.stubs(:statuses_smart_proxies).returns([])
    Ping.stubs(:statuses_compute_resources).returns([])
    Ping.stubs(:ping_database).returns(foreman_database_response)
    expected_result = {
      'foreman': {
        version: SETTINGS[:version].full,
        api: {
          version: Apipie.configuration.default_version,
        },
        plugins: [
          {
            name: 'foo',
            version: '1.0.0',
          },
        ],
        smart_proxies: [],
        compute_resources: [],
        database: foreman_database_response,
      },
      'foo': plugin_status_response,
    }
    assert_equal expected_result, Ping.statuses
  end

  def test_add_provision_method
    Foreman::Plugin.register :awesome_provision do
      name 'Awesome provision'
      provision_method 'awesome', 'Awesomeness Based'
    end
    assert_equal 'Awesomeness Based', Host::Managed.provision_methods['awesome']
  end

  def test_register_facet
    Facets.stubs(:configuration).returns({})

    Foreman::Plugin.register :awesome_facet do
      name 'Awesome facet'
      register_facet(Awesome::FakeFacet, :fake_facet) do
        api_view :list => 'api/v2/awesome/index', :single => 'api/v2/awesome/show'
      end
    end

    assert Facets.registered_facets[:fake_facet]

    Host::Managed.cloned_parameters[:include].delete(:fake_facet)
  end

  def test_register_facet_resilience
    old_config = Facets.instance_variable_get('@configuration')
    Facets.instance_variable_set('@configuration', nil)

    Foreman::Plugin.register :awesome_facet do
      name 'Awesome facet'
      register_facet(Awesome::FakeFacet, :fake_facet) do
        api_view :list => 'api/v2/awesome/index', :single => 'api/v2/awesome/show'
      end
    end

    # reset the configuration
    Facets.instance_variable_set('@configuration', nil)

    assert Facets.registered_facets[:fake_facet]

    Host::Managed.cloned_parameters[:include].delete(:fake_facet)
    Facets.instance_variable_set('@configuration', old_config)
  end

  def test_add_template_label
    kind = FactoryBot.build_stubbed(:template_kind)
    Foreman::Plugin.register :test_template_kind do
      name 'Test template kind'
      template_labels kind.name => 'Test plugin template kind'
    end
    assert_equal 'Test plugin template kind', kind.to_s
  end

  def test_add_parameter_filter
    Foreman::Plugin.register :test_parameter_filter do
      name 'Parameter filter test'
      parameter_filter Domain, :foo, :bar => [], :ui => true
    end
    assert_equal([], Foreman::Plugin.find(:test_parameter_filter).parameter_filters(User))
    assert_equal([[:foo, :bar => [], :ui => true]], Foreman::Plugin.find(:test_parameter_filter).parameter_filters(Domain))
    assert_equal([[:foo, :bar => [], :ui => true]], Foreman::Plugin.find(:test_parameter_filter).parameter_filters('Domain'))
  end

  def test_add_parameter_filter_block
    Foreman::Plugin.register :test_parameter_filter do
      name 'Parameter filter test'
      parameter_filter(Domain) { |ctx| ctx.permit(:foo) }
    end
    assert_kind_of Proc, Foreman::Plugin.find(:test_parameter_filter).parameter_filters(Domain).first.first
  end

  def test_add_smart_proxy_for
    Foreman::Plugin.register :test_smart_proxy do
      name 'Smart Proxy test'
      smart_proxy_for Awesome, :foo, :feature => 'Foo'
    end
    assert_equal({}, Foreman::Plugin.find(:test_smart_proxy).smart_proxies(User))
    assert_equal({:foo => {:feature => 'Foo'}}, Foreman::Plugin.find(:test_smart_proxy).smart_proxies(Awesome))
  end

  def test_hosts_controller_action_scope
    mock_scope = ->(scope) { scope }
    Foreman::Plugin.register :test_hosts_controller_action_scope do
      add_controller_action_scope 'HostsController', :test_action, &mock_scope
    end
    scopes = HostsController.scopes_for(:test_action)
    assert_equal mock_scope, scopes.last
  end

  def test_hosts_controller_action_scope_added_to_local
    mock_scope = ->(scope) { scope }
    HostsController.add_scope_for(:test_action) do |scope|
      scope
    end
    Foreman::Plugin.register :test_hosts_controller_action_scope_added_to_local do
      add_controller_action_scope 'HostsController', :test_action, &mock_scope
    end
    scopes = HostsController.scopes_for(:test_action)
    assert_equal 2, scopes.count
  end

  def test_add_resource_permissions_to_defalut_roles
    Foreman::Plugin.register :test_plugin do
      add_resource_permissions_to_default_roles ["Test::Resource"], :except => [:create_test]
    end
    manager = Role.find_by :name => "Manager"
    org_admin = Role.find_by :name => "Organization admin"
    viewer = Role.find_by :name => "Viewer"
    assert_equal 2, manager.permissions.where(:resource_type => "Test::Resource").count
    assert_equal 2, org_admin.permissions.where(:resource_type => "Test::Resource").count
    assert_equal 1, viewer.permissions.where(:resource_type => "Test::Resource").count
  end

  def test_add_permissions_to_default_roles
    viewer = Role.find_by :name => "Viewer"
    refute viewer.permissions.find_by :name => "misc_test"
    Foreman::Plugin.register :test_plugin do
      add_permissions_to_default_roles "Viewer" => [:misc_test]
    end
    assert viewer.permissions.find_by :name => "misc_test"
  end

  def test_add_all_permissions_to_default_roles
    # Plugin api does not save permissions in tests
    Permission.where(:name => 'restricted').first_or_create()
    Foreman::Plugin.register :test_plugin do
      security_block :test_permission do
        permission :view_test, { :controller_name => [:test] }
        permission :edit_test, { :controller_name => [:test] }
        permission :create_test, { :controller_name => [:test] }
        permission :misc_test, { :controller_name => [:test] }
        permission :restricted, { :controller_name => [:test] }
      end
      add_all_permissions_to_default_roles(except: [:restricted])
    end
    manager = Role.find_by :name => "Manager"
    viewer = Role.find_by :name => "Viewer"
    org_admin = Role.find_by :name => "Organization admin"

    %w(view_test).each do |perm|
      permission = Permission.find_by(:name => perm)
      assert permission.roles.include?(manager)
      assert permission.roles.include?(viewer)
      assert permission.roles.include?(org_admin)
    end

    %w(edit_test create_test misc_test).each do |perm|
      permission = Permission.find_by(:name => perm)
      assert permission.roles.include?(manager)
      assert permission.roles.include?(org_admin)
      refute permission.roles.include?(viewer)
    end

    permission = Permission.find_by(:name => 'restricted')
    refute permission.roles.include?(manager)
    refute permission.roles.include?(org_admin)
    refute permission.roles.include?(viewer)
    permission.destroy
  end

  def test_add_dashboard_widget
    widget_params = {template: 'plugin_widget', name: 'Plugin Widget', sizex: 2, sizey: 2}
    plugin = Foreman::Plugin.register :test_widget do
      widget 'plugin_widget', widget_params.except(:template)
    end
    assert_equal [widget_params], plugin.dashboard_widgets
    assert_includes Dashboard::Manager.default_widgets, widget_params
  end

  def test_extend_rabl_template
    Foreman::Plugin.register :test_extend_rabl_template do
      extend_rabl_template 'api/v2/hosts/main', 'api/v2/hosts/expiration'
    end
    templates = Foreman::Plugin.find(:test_extend_rabl_template).rabl_template_extensions('api/v2/hosts/main')
    assert_equal ['api/v2/hosts/expiration'], templates
  end

  def test_add_smart_proxy_reference
    refs = ProxyReferenceRegistry.smart_proxy_references
    ProxyReferenceRegistry.references = nil
    Foreman::Plugin.register :test_add_smart_proxy_reference do
      smart_proxy_reference :hosts => [:test]
    end
    assert_equal [:test], ProxyReferenceRegistry.find_by_relation(:hosts).columns
  ensure
    ProxyReferenceRegistry.references = refs
  end

  context "adding permissions" do
    teardown do
      permission = Foreman::AccessControl.permission(:test_permission)
      Foreman::AccessControl.remove_permission(permission) if permission
    end

    def test_add_permission
      Foreman::Plugin.register :test_permission do
        name 'Permission test'
        security_block :test_permission do
          permission :test_permission, {:controller_name => [:test]}
        end
      end
      assert_includes Foreman::Plugin.find(:test_permission).permission_names, :test_permission
      ac_permission = Foreman::AccessControl.permission(:test_permission)
      assert ac_permission, ":test_permission is not registered in Foreman::AccessControl"
      assert_equal ['controller_name/test'], ac_permission.actions
    end

    def test_add_role
      Foreman::Plugin.register :test_role do
        name 'Role test'
        security_block :test_permission do
          permission :test_permission, {:controller_name => [:test]}
        end
        role 'Test role', [:test_permission]
      end
      assert_equal({'Test role' => [:test_permission]}, Foreman::Plugin.find(:test_role).default_roles)
    end
  end

  context "asset precompilation" do
    teardown do
      Rails.application.config.assets.precompile.delete_if { |f| f.is_a?(String) && f.start_with?('test_assets_') }
    end

    def test_assets_from_precompile_assets
      plugin = Foreman::Plugin.register(:test_assets_from_precompile_assets) do
        precompile_assets 'test_assets_example.js', 'test_assets_another.css'
      end
      assert_equal ['test_assets_example.js', 'test_assets_another.css'], plugin.assets
      assert_include Rails.application.config.assets.precompile, 'test_assets_example.js'
    end

    def test_assets_from_root
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'app', 'assets', 'javascripts', 'test_assets_from_root')
        FileUtils.touch File.join(root, 'app', 'assets', 'javascripts', 'test_outside.js')
        FileUtils.touch File.join(root, 'app', 'assets', 'javascripts', 'test_assets_from_root', 'test_assets_example.js')

        Rails.logger.stubs(:debug)
        Rails.logger.expects(:debug).with(regexp_matches(/test_outside\.js/))
        plugin = Foreman::Plugin.register(:test_assets_from_root) do
          path root
        end
        assert_equal ['test_assets_from_root/test_assets_example.js'], plugin.assets
        assert_include Rails.application.config.assets.precompile, 'test_assets_from_root/test_assets_example.js'
      end
    end

    def test_assets_without_automatic
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'app', 'assets', 'javascripts', 'test_assets_without_automatic')
        FileUtils.touch File.join(root, 'app', 'assets', 'javascripts', 'test_assets_without_automatic', 'test_assets_example.js')

        plugin = Foreman::Plugin.register(:test_assets_without_automatic) do
          path root
          automatic_assets false
        end
        assert_equal [], plugin.assets
      end
    end
  end

  context 'with pagelets' do
    include PageletsIsolation

    def test_extend_page
      Foreman::Plugin.register(:foo) do
        extend_page("tests/show") do |context|
          context.add_pagelet :main_tabs, :name => "My Tab", :partial => "partial"
        end
      end

      assert_equal 1, ::Pagelets::Manager.pagelets_at("tests/show", :main_tabs).count
      assert_equal "My Tab", ::Pagelets::Manager.pagelets_at("tests/show", :main_tabs).first.name
    end
  end

  describe 'Report scanner' do
    subject { Foreman::Plugin.register('test') {} }
    let(:report_scanner) { stub_everything('Object') }

    describe '.register_report_scanner' do
      it 'adds a class to report_scanner' do
        refute subject.class.registered_report_scanners.include? report_scanner
        subject.register_report_scanner report_scanner
        assert subject.class.registered_report_scanners.include? report_scanner
      end
    end

    describe '.unregister_report_scanner' do
      before do
        subject.register_report_scanner report_scanner
      end

      it 'removes a class to report_scanner' do
        assert subject.class.registered_report_scanners.include? report_scanner
        subject.unregister_report_scanner report_scanner
        refute subject.class.registered_report_scanners.include? report_scanner
      end
    end
  end

  describe 'graphql type extensions' do
    subject { Foreman::Plugin.register('test') {} }

    it 'registers a graphql type extension' do
      assert_empty subject.graphql_types_registry.type_block_extensions
      subject.extend_graphql_type(type: Class.new) do
        def foo
        end
      end
      assert_not_empty subject.graphql_types_registry.type_block_extensions
    end
  end
end
