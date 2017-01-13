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

class MenuMapperTest < ActiveSupport::TestCase
  test "Mapper#initialize should define a root MenuNode if menu is not present in items" do
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    node = menu_mapper.menu_items
    assert_not_nil node
    assert_equal :root, node.name
  end

  test "Mapper#initialize should use existing MenuNode if present" do
    node = "foo" # just an arbitrary reference
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {:test_menu => node})
    assert_equal node, menu_mapper.menu_items
  end

  def test_push_onto_root
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}

    menu_mapper.exists?(:test_overview)
  end

  def test_push_onto_parent
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_child, :url_hash => { :controller => 'hosts', :action => 'show'}, :parent => :test_overview

    assert menu_mapper.exists?(:test_child)
    assert_equal :test_child, menu_mapper.find(:test_child).name
  end

  def test_push_onto_grandparent
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_child, :url_hash => { :controller => 'hosts', :action => 'show'}, :parent => :test_overview
    menu_mapper.item :test_grandchild, :url_hash => { :controller => 'hosts', :action => 'show'}, :parent => :test_child

    assert menu_mapper.exists?(:test_grandchild)
    grandchild = menu_mapper.find(:test_grandchild)
    assert_equal :test_grandchild, grandchild.name
    assert_equal :test_child, grandchild.parent.name
  end

  def test_push_first
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_second, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_third, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fourth, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fifth, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_first, :url_hash => { :controller => 'hosts', :action => 'show'}, :first => true

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    {0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth}.each do |position, name|
      assert_not_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  def test_push_before
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_first, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_second, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fourth, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fifth, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_third, :url_hash => { :controller => 'hosts', :action => 'show'}, :before => :test_fourth

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    {0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth}.each do |position, name|
      assert_not_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  def test_push_after
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_first, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_second, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_third, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fifth, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fourth, :url_hash => { :controller => 'hosts', :action => 'show'}, :after => :test_third

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    {0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth}.each do |position, name|
      assert_not_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  def test_push_last
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_first, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_second, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_third, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_fifth, :url_hash => { :controller => 'hosts', :action => 'show'}, :last => true
    menu_mapper.item :test_fourth, :url_hash => { :controller => 'hosts', :action => 'show'}

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    {0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth}.each do |position, name|
      assert_not_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  def test_exists_for_child_node
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}
    menu_mapper.item :test_child, :url_hash => { :controller => 'hosts', :action => 'show'}, :parent => :test_overview

    assert menu_mapper.exists?(:test_child)
  end

  def test_exists_for_invalid_node
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}

    assert !menu_mapper.exists?(:nothing)
  end

  def test_find
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}

    item = menu_mapper.find(:test_overview)
    assert_equal :test_overview, item.name
    assert_equal({:controller => 'hosts', :action => 'show'}, item.url_hash)
  end

  def test_find_missing
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}

    item = menu_mapper.find(:nothing)
    assert_equal nil, item
  end

  def test_delete
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.item :test_overview, :url_hash => { :controller => 'hosts', :action => 'show'}
    assert_not_nil menu_mapper.delete(:test_overview)

    assert_nil menu_mapper.find(:test_overview)
  end

  def test_delete_in_sub_menu
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    menu_mapper.sub_menu :test_sub_menu, :caption => "Sub Menu" do
      menu_mapper.item :test_sub_overview, :url_hash => { :controller => 'hosts', :action => 'show'}
    end
    assert_not_nil menu_mapper.find(:test_sub_overview)

    assert_not_nil menu_mapper.delete(:test_sub_overview)

    assert_nil menu_mapper.find(:test_sub_overview)
  end

  def test_delete_missing
    menu_mapper = Menu::Manager::Mapper.new(:test_menu, {})
    assert_nil menu_mapper.delete(:test_missing)
  end

  test 'deleting all items' do
    # Exposed by deleting :last items
    Menu::Manager.map :test_menu do |menu|
      menu.item :not_last, :url_hash=>  { :controller => 'hosts', :action => 'index'}
      menu.item :administration, :url_hash=> { :controller => 'hosts', :action => 'show'}, :last => true
      menu.item :help, :url_hash => { :controller => 'help', :action => 'show'}, :last => true
    end

    assert_nothing_raised do
      Menu::Manager.map :test_menu do |menu|
        menu.delete(:administration)
        menu.delete(:help)
        menu.item :test_overview, :url_hash => { :controller => 'dashboard', :action => 'index'}
      end
    end
  end

  def test_hash_consistency
    m1 = Menu::Manager::Mapper.new(:test_menu1, {})
    m1.item :test_item, :caption => "Some Item", :url_hash => { :controller => 'hosts', :action => 'show'}
    m1.divider
    m1.sub_menu :test_sub_menu, :caption => "Some Sub-menu" do
      m1.item :test_sub_item, :caption => "Some Sub-item", :url_hash => { :controller => 'hosts', :action => 'show'}
    end
    m2 = Menu::Manager::Mapper.new(:test_menu2, {})
    m2.item :test_item, :caption => "Some Item", :url_hash => { :controller => 'hosts', :action => 'show'}
    m2.divider
    m2.sub_menu :test_sub_menu, :caption => "Some Sub-menu" do
      m2.item :test_sub_item, :caption => "Some Sub-item", :url_hash => { :controller => 'hosts', :action => 'show'}
    end
    assert_equal m1.find(:root).content_hash, m2.find(:root).content_hash
  end

  def test_hash_item_change
    m1 = Menu::Manager::Mapper.new(:test_menu1, {})
    m1.item :test_item, :caption => "Some Item", :url_hash => { :controller => 'hosts', :action => 'show'}
    m2 = Menu::Manager::Mapper.new(:test_menu2, {})
    m2.item :test_item, :caption => "Some Changed Item", :url_hash => { :controller => 'hosts', :action => 'show'}
    assert_not_equal m1.find(:root).content_hash, m2.find(:root).content_hash
  end

  def test_hash_url_change
    m1 = Menu::Manager::Mapper.new(:test_menu1, {})
    m1.item :test_item, :caption => "Some Item", :url_hash => { :controller => 'hosts', :action => 'show'}
    m2 = Menu::Manager::Mapper.new(:test_menu2, {})
    m2.item :test_item, :caption => "Some Item", :url_hash => { :controller => 'facts', :action => 'show'}
    assert_not_equal m1.find(:root).content_hash, m2.find(:root).content_hash
  end

  def test_hash_submenu_change
    m1 = Menu::Manager::Mapper.new(:test_menu1, {})
    m1.sub_menu :test_sub_menu, :caption => "Some Sub-menu" do
      m1.item :test_sub_item, :caption => "Some Sub-item", :url_hash => { :controller => 'hosts', :action => 'show'}
    end
    m2 = Menu::Manager::Mapper.new(:test_menu2, {})
    m2.sub_menu :test_sub_menu, :caption => "Renamed Sub-menu" do
      m2.item :test_sub_item, :caption => "Some Sub-item", :url_hash => { :controller => 'hosts', :action => 'show'}
    end
    assert_not_equal m1.find(:root).content_hash, m2.find(:root).content_hash
  end
end
