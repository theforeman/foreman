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

module Foreman #:nodoc:

  class PluginNotFound < Foreman::Exception; end
  class PluginRequirementError < Foreman::Exception; end

  # Base class for Foreman plugins.
  # Plugins are registered using the <tt>register</tt> class method that acts as the public constructor.
  #
  #   Foreman::Plugin.register :example do
  #     name 'Example plugin'
  #     author 'John Smith'
  #     description 'This is an example plugin for Foreman'
  #     version '0.0.1'
  #   end
  #
  class Plugin

    @registered_plugins = {}
    @tests_to_skip = {}
    class << self
      attr_reader   :registered_plugins
      attr_accessor :tests_to_skip
      private :new

      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end

      # Plugin constructor
      def register(id, &block)
        plugin = new(id)
        if (gem = Gem.loaded_specs[id.to_s])
          plugin.name gem.name
          plugin.author gem.authors.join(',')
          plugin.description gem.description
          plugin.url gem.homepage
          plugin.version gem.version.to_s
        end

        plugin.instance_eval(&block)

        registered_plugins[id] = plugin
      end

      # Clears the registered plugins hash
      # It doesn't unload installed plugins
      def clear
        @registered_plugins = {}
      end

      # Returns an array of all registered plugins
      def all
        registered_plugins.values.sort
      end

      # Finds a plugin by its id
      def find(id)
        registered_plugins[id.to_sym]
      end

      # Checks if a plugin is installed
      #
      # @param [String] id name of the plugin
      def installed?(id)
        registered_plugins[id.to_sym].present?
      end
    end

    def_field :name, :description, :url, :author, :author_url, :version
    attr_reader :id

    def initialize(id)
      @id = id.to_sym
    end


    def <=>(plugin)
      self.id.to_s <=> plugin.id.to_s
    end

    def to_s
      "Foreman plugin: #{id}, #{version}, #{author}, #{description}"
    end

    # Sets a requirement on Foreman version
    # Raises a PluginRequirementError exception if the requirement is not met
    # matcher format is gem dependency format
    def requires_foreman(matcher)
      current = SETTINGS[:version].notag
      unless Gem::Dependency.new('', matcher).match?('', current)
        raise PluginRequirementError.new(N_("%{id} plugin requires Foreman %{matcher} but current is %{current}" % {:id=>id, :matcher => matcher, :current=>current}))
      end
      true
    end

    # Sets a requirement on a Foreman plugin version
    # Raises a PluginRequirementError exception if the requirement is not met
    # matcher format is gem dependency format
    def requires_foreman_plugin(plugin_name, matcher)
      plugin = Plugin.find(plugin_name)
      raise PluginNotFound.new(N_("%{id} plugin requires the %{plugin_name} plugin, not found") % {:id =>id, :plugin_name=>plugin_name}) unless plugin
      unless Gem::Dependency.new('', matcher).match?('', plugin.version)
        raise PluginRequirementError.new(N_("%{id} plugin requires the %{plugin_name} plugin %{matcher} but current is %{plugin_version}" % {:id=>id, :plugin_name=>plugin_name,:matcher=> matcher,:plugin_version=>plugin.version}))
      end
      true
    end

    # Adds an item to the given menu
    # The id parameter is automatically added to the url.
    #   menu :menu_name, :plugin_example, 'menu text', { :controller => :example, :action => :index }
    #
    # name parameter can be: :top_menu or :admin_menu
    #
    def menu(menu, name, options = {})
      options.merge!(:parent => @parent) if @parent
      Menu::Manager.map(menu).item(name, options)
    end

    alias_method :add_menu_item, :menu

    def sub_menu(menu, name, options = {}, &block)
      options.merge!(:parent => @parent) if @parent
      Menu::Manager.map(menu).sub_menu(name, options)
      current = @parent
      @parent = name
      self.instance_eval(&block) if block_given?
      @parent = current
    end

    def divider(menu, options = {})
      Menu::Manager.map(menu).divider(options)
    end

    # Removes item from the given menu
    def delete_menu_item(menu, item)
      Menu::Manager.map(menu).delete(item)
    end

    def tests_to_skip(hash)
      # Format is { "testclass" => [ "skip1", "skip2" ] }
      hash.each do |testclass,tests|
        if self.class.tests_to_skip[testclass].nil?
          self.class.tests_to_skip[testclass] = tests
        else
          self.class.tests_to_skip[testclass] = self.class.tests_to_skip[testclass].push(tests).flatten.uniq
        end
      end
    end

    def security_block(name, &block)
      @security_block = name
      self.instance_eval(&block)
      @security_block = nil
    end

    # Defines a permission called name for the given controller=>actions
    # :options can contain :resource_type key which is the string of resource
    #   class to which this permissions is related, rest of options is passed
    #   to AccessControl
    def permission(name, hash, options = {})
      return false if pending_migrations

      options[:engine] ||= self.id.to_s
      Permission.find_or_create_by_name_and_resource_type(name, options[:resource_type])
      options.merge!(:security_block => @security_block)
      Foreman::AccessControl.map do |map|
        map.permission name, hash, options
      end
    end

    # Add a new role if it doesn't exist
    def role(name, permissions)
      return false if pending_migrations

      Role.transaction do
        role = Role.find_or_create_by_name(name)
        role.add_permissions!(permissions) if role.permissions.empty?
      end
    end

    def pending_migrations
      migrations = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths).pending_migrations
      migrations.size > 0
    end

    # List of helper methods allowed for templates in safe mode
    def allowed_template_helpers(*helpers)
      Foreman::Renderer::ALLOWED_HELPERS.concat(helpers)
    end

    # List of variables allowed for templates in safe mode
    def allowed_template_variables(*variables)
      Foreman::Renderer::ALLOWED_VARIABLES.concat(variables)
    end

    # Add Compute resource
    def compute_resource(provider)
      SETTINGS[provider.name.split('::').last.downcase.to_sym] = true
      ComputeResource.register_provider provider
    end

    def widget(id, options)
      Dashboard::Manager.map.widget(id, options)
    end

    # To add FiltersHelper#search_path override,
    # in lib/engine.rb, in plugin initialization block:
    # search_path_override("EngineModuleName") { |resource| ... }
    def search_path_override(engine_name, &blk)
      if block_given?
        FiltersHelperOverrides.override_search_path(engine_name, blk)
      else
        Rails.logger.warn "Ignoring override of FiltersHelper#search_path_override for '#{engine_name}': no override block is present"
      end
    end
  end
end
