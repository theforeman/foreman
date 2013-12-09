# Redmine - project management software
# Copyright (C) 2006-2009  Jean-Philippe Lang
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

module MenuItemTestHelper
  # Helpers
  def get_menu_item(menu_name, item_name)
    Menu::Manager.items(menu_name).find {|item| item.name == item_name.to_sym}
  end
end

class MenuItemTest < ActiveSupport::TestCase
  include MenuItemTestHelper

  Menu::Manager.map :test_menu do |menu|
    menu.item(:parent)
    menu.item(:child_menu, :parent => :parent)
    menu.item(:child2_menu, :parent => :parent)
  end

  context "MenuItem#caption" do
    should "be tested"
  end

  context "MenuItem#html_options" do
    should "be tested"
  end

  def test_new_menu_item_with_all_required_parameters
    assert Menu::Item.new(:test_good_menu, :url_hash => {:controller=>'test', :action=>'index'}, :after => :me)
  end

  def test_new_menu_item_should_require_a_proc_to_use_for_the_if_condition
    assert_raises ArgumentError do
      Menu::Item.new(:test_error, :if => ['not_a_proc'] )
    end

    assert Menu::Item.new(:test_good_if, :if => Proc.new{})
  end

  def test_new_menu_item_should_allow_a_hash_for_extra_html_options
    assert_raises ArgumentError do
      Menu::Item.new(:test_error, :html => ['not_a_hash'])
    end

    assert Menu::Item.new(:test_good_html, :html => { :onclick => 'doSomething' })
  end

  def test_new_menu_item_should_require_a_proc_to_use_the_children_option
    assert_raises ArgumentError do
      Menu::Item.new(:test_error, :children => ['not_a_proc'])
    end

    assert Menu::Item.new(:test_good_children, :children => Proc.new{} )
  end

  def test_new_should_not_allow_setting_the_parent_item_to_the_current_item
    assert_raises ArgumentError do
      Menu::Item.new(:test_error, :parent => :test_error )
    end
  end

  def test_has_children
    parent_item = get_menu_item(:test_menu, :parent)
    assert parent_item.children.present?
    assert_equal 2, parent_item.children.size
    assert_equal get_menu_item(:test_menu, :child_menu), parent_item.children[0]
    assert_equal get_menu_item(:test_menu, :child2_menu), parent_item.children[1]
  end

  def test_allow_setting_path
    item = Menu::Item.new(:test_menu, :url_hash => {:path => 'test_path'})

    assert_equal item.path, 'test_path'
  end
end
