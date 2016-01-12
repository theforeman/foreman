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

module Awesome; module Provider; class MyAwesome < ::ComputeResource; end; end; end

class PluginTest < ActiveSupport::TestCase
  def setup
    @klass = Foreman::Plugin
    # In case some real plugins are installed
    @klass.clear
  end

  def teardown
    @klass.clear
  end

  def test_register
    @klass.register :foo do
      name 'Foo plugin'
      url 'http://example.net/plugins/foo'
      author 'John Smith'
      author_url 'http://example.net/jsmith'
      description 'This is a test plugin'
      version '0.0.1'
      path '/some/path/on/disk'
    end

    assert_equal 1, @klass.all.size

    plugin = @klass.find('foo')
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
    @klass.register(:foo) {}
    assert_equal true, @klass.installed?(:foo)
    assert_equal false, @klass.installed?(:bar)
  end

  def test_menu
    url_hash = {:controller=>'hosts', :action=>'index'}
    assert_difference 'Menu::Manager.items(:project_menu).size' do
      @klass.register :foo do
        menu :project_menu, :foo_menu_item, :url_hash=>url_hash, :caption => 'Foo'
      end
    end
    menu_item = Menu::Manager.items(:project_menu).detect {|i| i.name == :foo_menu_item}
    assert_not_nil menu_item
    assert_equal 'Foo', menu_item.caption
    assert_equal url_hash, menu_item.url_hash
  end

  def test_delete_menu_item
    Menu::Manager.map(:project_menu).item(:foo_menu_item, :caption => 'Foo')
    assert_difference 'Menu::Manager.items(:project_menu).size', -1 do
      @klass.register :foo do
        delete_menu_item :project_menu, :foo_menu_item
      end
    end
    assert_nil Menu::Manager.items(:project_menu).detect {|i| i.name == :foo_menu_item}
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
    @klass.register :other do
      name 'Other'
      version other_version
    end
    @klass.register :foo do
      test.assert requires_foreman_plugin(:other, '>= 0.1.0')
      test.assert requires_foreman_plugin(:other, other_version)
      test.assert_raise Foreman::PluginRequirementError do
        requires_foreman_plugin(:other, '>= 99.0.0')
      end
      test.assert_raise Foreman::PluginRequirementError do
        requires_foreman_plugin(:other, '= 99.0.0')
      end

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

  def test_register_allowed_template_helpers_and_variables
    refute_includes Foreman::Renderer::ALLOWED_HELPERS, :my_helper
    refute_includes Foreman::Renderer::ALLOWED_VARIABLES, :my_variable

    @klass.register :foo do
      allowed_template_helpers :my_helper
      allowed_template_variables :my_variable
    end

    assert_includes Foreman::Renderer::ALLOWED_HELPERS, :my_helper
    assert_includes Foreman::Renderer::ALLOWED_VARIABLES, :my_variable
  ensure
    Foreman::Renderer::ALLOWED_HELPERS.delete(:my_helper)
    Foreman::Renderer::ALLOWED_HELPERS.delete(:my_variable)
  end

  def test_add_compute_resource
    Foreman::Plugin.register :awesome_compute do
      name 'Awesome compute'
      compute_resource Awesome::Provider::MyAwesome
    end
    assert ComputeResource.providers.must_include 'MyAwesome'
    assert_equal ComputeResource.provider_class('MyAwesome'), 'Awesome::Provider::MyAwesome'
    assert ComputeResource.supported_providers.keys.must_include 'MyAwesome'
    assert ComputeResource.supported_providers.values.must_include 'Awesome::Provider::MyAwesome'
    assert SETTINGS[:myawesome]
  end

  def test_add_search_path_override
    Foreman::Plugin.register :filter_helpers do
      search_path_override("TestEngine") { |resource| "test_engine/another_search_path" }
    end
    assert FiltersHelperOverrides.can_override?("TestEngine::TestResource")
  end

  def test_can_merge_tests_to_skip_arrays
    @klass.register :foo do
      tests_to_skip "FooTest" => [ "test1", "test2" ]
    end
    @klass.register :bar do
      tests_to_skip "FooTest" => [ "test3", "test4" ]
    end
    assert_equal [ "test1", "test2", "test3", "test4" ], @klass.tests_to_skip["FooTest"]
  end

  def test_configure_logging
    Foreman::Plugin::Logging.any_instance.expects(:configure).with(nil)
    @klass.register(:foo) {}

    assert Foreman::Plugin.find(:foo).logging
  end

  def test_logger
    Foreman::Plugin::Logging.any_instance.expects(:configure).with(nil)
    @klass.register(:foo) {}
    plugin = Foreman::Plugin.find(:foo)

    plugin.logging.expects(:add_logger).with(:test_logger, {:enabled => true})
    plugin.logger(:test_logger, {:enabled => true})
  end

  def test_register_custom_status
    status = Struct.new(:status)
    @klass.register :foo do
      register_custom_status(status)
    end
    assert_include HostStatus.status_registry, status
    HostStatus.status_registry.delete status
  end

  def test_add_provision_method
    Foreman::Plugin.register :awesome_provision do
      name 'Awesome provision'
      provision_method 'awesome', 'Awesomeness Based'
    end
    assert_equal 'Awesomeness Based', Host::Managed.provision_methods['awesome']
  end

  def test_extend_page
    Foreman::Plugin.register(:foo) do
      extend_page("tests/show") do |context|
        context.add_pagelet :main_tabs, :name => "My Tab", :partial => "partial"
      end
    end

    assert_equal 1, ::Pagelets::Manager.sorted_pagelets_at("tests/show", :main_tabs).count
    assert_equal "My Tab", ::Pagelets::Manager.sorted_pagelets_at("tests/show", :main_tabs).first.name
  end
end
