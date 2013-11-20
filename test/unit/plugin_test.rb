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
end
