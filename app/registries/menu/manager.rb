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
module Menu
  module Manager
    class << self
      def map(menu_name)
        @items ||= {}
        mapper = Mapper.new(menu_name.to_sym, @items)
        if block_given?
          yield mapper
        else
          mapper
        end
      end

      def items(menu_name)
        # force menu reload in development when auto loading modified files
        @items || Menu::Loader.load
        @items[menu_name.to_sym] || Node.new(:root)
      end

      def to_hash(menu_name)
        items(menu_name).authorized_children.map(&:to_hash)
      end

      def get_resource_caption(resource)
        items = (@items[:top_menu].children + @items[:admin_menu].children)
        menu_title = items.map do |submenu|
          submenu.children.find { |item| item.name == resource }&.caption
        end.compact.first
        menu_title || resource.to_s.pluralize.titleize
      end
    end

    class Mapper
      attr_reader :menu, :menu_items

      def initialize(menu, items)
        items[menu] ||= Node.new(:root)
        @menu = menu
        @menu_items = items[menu]
      end

      # Adds an item at the end of the menu. Available options:
      # * param: the parameter name that is used for the project id (default is :id)
      # * if: a Proc that is called before rendering the item, the item is displayed only if it returns true
      # * caption that can be:
      #   * a localized string Symbol
      #   * a String
      #   * a Proc that can take the project as argument
      # * before, after: specify where the menu item should be inserted (eg. :after => :activity)
      # * parent: menu item will be added as a child of another named menu (eg. :parent => :issues)
      # * children: a Proc that is called before rendering the item. The Proc should return an array of MenuItems, which will be added as children to this item.
      #   eg. :children => Proc.new {|project| [Foreman::Manager::MenuItem.new(...)] }
      # * last: menu item will stay at the end (eg. :last => true)
      # * html_options: a hash of html options that are passed to link_to
      def push(obj, options = {})
        parent = options[:parent] || @parent

        target_root = (parent && (subtree = find(parent))) ? subtree : @menu_items.root

        # menu item position
        if options[:first]
          target_root.prepend(obj)
        elsif (before = options[:before]) && exists?(before)
          target_root.add_at(obj, position_of(before))
        elsif (after = options[:after]) && exists?(after)
          target_root.add_at(obj, position_of(after) + 1)
        elsif options[:last]
          target_root.add_last(obj)
        else
          target_root.add(obj)
        end
      end

      def item(name, options = {})
        push(Item.new(name, options), options)
      end

      def sub_menu(name, options = {}, &block)
        push(Toggle.new(name, options[:caption], options[:icon]), options)
        current = @parent
        @parent = name
        instance_eval(&block) if block_given?
        @parent = current
      end

      def divider(options = {})
        push(Divider.new(:divider, options), options)
      end

      # Removes a menu item
      def delete(name)
        @menu_items.each do |item|
          if item.name == name && !item.parent.nil?
            return item.parent.remove!(item)
          end
        end
        nil
      end

      # Checks if a menu item exists
      def exists?(name)
        @menu_items.any? { |node| node.name == name }
      end

      def find(name)
        @menu_items.find { |node| node.name == name }
      end

      def position_of(name)
        @menu_items.each { |node| return node.position if node.name == name }
      end
    end
  end
end
