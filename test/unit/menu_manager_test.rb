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

class MenuManagerTest < ActiveSupport::TestCase
  def test_map_should_yield_a_mapper
    assert_difference 'Menu::Manager.items(:test_menu).size' do
      Menu::Manager.map :test_menu do |mapper|
        assert_kind_of  Menu::Manager::Mapper, mapper
        mapper.item :new_item
      end
    end
  end

  def test_items_should_return_menu_items
    items = Menu::Manager.items(:test_menu)
    assert_kind_of Menu::Node, items.first
  end

  def test_hashed_menu
    create_nested_menu
    Menu::Item.any_instance.stubs(:authorized?).returns(true)
    items = Menu::Manager.to_hash(:nested_menu)
    assert_equal menu_hash, items
  end

  def test_should_return_caption
    caption = Menu::Manager.get_resource_caption(:test_item)
    assert_equal caption, 'Test Items'
  end

  private

  def menu_hash
    [{:type => :sub_menu,
      :name => "User",
      :icon => "fa-icon",
      :children =>
        [{:type => :item, :exact => false, :html_options => {}, :name => "Item", :url => "some url"},
         {:type => :item, :exact => false, :html_options => {}, :name => "Item 2", :url => "some url"},
         {:type => :item, :exact => false, :html_options => {}, :name => "Test Items", :url => "some url"}]},
     {:type => :sub_menu,
      :name => "User",
      :icon => "fa-icon",
      :children => [{:type => :item, :exact => false, :html_options => {}, :name => "Item 3", :url => "some url"}]}]
  end

  def create_nested_menu
    Menu::Manager.map :nested_menu do |menu|
      menu.sub_menu :sub_menu_one, :caption => 'User', :icon => 'fa-icon' do
        menu.item :item_one,
          caption: 'Item',
          url: 'some url'
        menu.item :item_two,
          caption: 'Item 2',
          url: 'some url'
        menu.item :test_item,
          caption: 'Test Items',
          url: 'some url'
      end
      menu.sub_menu :sub_menu_two, :caption => 'User', :icon => 'fa-icon' do
        menu.item :item_three,
          caption: 'Item 3',
          url: 'some url'
      end
    end
  end
end
