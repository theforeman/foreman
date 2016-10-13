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

require_relative 'plugin/logging'

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
          plugin.path gem.full_gem_path
        end

        plugin.instance_eval(&block)
        plugin.after_initialize

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

    def_field :name, :description, :url, :author, :author_url, :version, :path
    attr_reader :id, :logging, :default_roles, :provision_methods, :compute_resources, :to_prepare_callbacks, :permissions

    def initialize(id)
      @id = id.to_sym
      @logging = Plugin::Logging.new(@id)
      @default_roles = {}
      @provision_methods = {}
      @compute_resources = []
      @to_prepare_callbacks = []
      @template_labels = {}
      @parameter_filters = {}
      @smart_proxies = {}
      @permissions = {}
    end

    def after_initialize
      configure_logging
    end

    def configure_logging
      @logging.configure(SETTINGS[@id])
    end

    def logger(name, configuration = {})
      @logging.add_logger(name, configuration)
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

    # Extends page by adding custom pagelet to a mountpoint.
    # Usage:
    #
    # extend_page("hosts/_form") do |context|
    #   context.add_pagelet :mountpoint,
    #                       :name => N_("Example Pagelet"),
    #                       :partial => "path/to/partial",
    #                       :priority => 10000,
    #                       :id => 'custom-html-id',
    #                       :onlyif => Proc.new { |subject| subject.should_show_pagelet? }
    # end
    def extend_page(virtual_path, &block)
      yield Pagelets::Manager.new(virtual_path) if block_given?
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
      @permissions[name] = options.slice(:resource_type)

      options[:engine] ||= self.id.to_s
      options.merge!(:security_block => @security_block)
      Foreman::AccessControl.map do |map|
        map.permission name, hash, options
      end

      return false if pending_migrations || Rails.env.test?
      Permission.where(:name => name).first_or_create(:resource_type => options[:resource_type])
    end

    # Add a new role if it doesn't exist
    def role(name, permissions)
      @default_roles[name] = permissions
      return false if pending_migrations || Rails.env.test?

      Role.transaction do
        role = Role.where(:name => name).first_or_create
        role.add_permissions!(permissions) if role.permissions.empty?
      end
    end

    def pending_migrations
      migration_paths = ActiveRecord::Migrator.migrations(
        ActiveRecord::Migrator.migrations_paths)
      pending_migrations = ActiveRecord::Migrator.new(:up, migration_paths).
        pending_migrations

      return false if pending_migrations.empty?
      migration_names = pending_migrations.take(5).map(&:name).join(', ')
      Rails.logger.debug(
        "There are #{pending_migrations.size} pending migrations: "\
        "#{migration_names}#{pending_migrations.size > 5 ? '...' : ''}")
      true
    end

    # List of helper methods allowed for templates in safe mode
    def allowed_template_helpers(*helpers)
      in_to_prepare do
        Foreman::Renderer::ALLOWED_HELPERS.concat(helpers).uniq!
      end
    end

    # List of variables allowed for templates in safe mode
    def allowed_template_variables(*variables)
      in_to_prepare do
        Foreman::Renderer::ALLOWED_VARIABLES.concat(variables).uniq!
      end
    end

    # List of modules which public methods will be available during template rendering
    # including safe mode
    def extend_template_helpers(*mods)
      in_to_prepare do
        mods.each do |mod|
          extend_template_helpers_by_module(mod.to_s)
        end
      end
    end

    # Add Compute resource
    def compute_resource(provider)
      return if @compute_resources.include?(provider)
      if !provider.is_a?(Class) || !(provider < ComputeResource)
        raise ::Foreman::Exception.new(N_("Cannot register compute resource, wrong type supplied"))
      end
      @compute_resources << provider.name
    end

    def widget(template, options)
      Dashboard::Manager.register_default_widget({:template=>template}.merge!(options))
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

    # list of API controller paths, globs allowed
    def apipie_documented_controllers(controllers = nil)
      if controllers
        @apipie_documented_controllers = controllers
        Apipie.configuration.api_controllers_matcher.concat(controllers)
      end
      @apipie_documented_controllers
    end

    # list of clontroller classnames that are ignored by apipie
    def apipie_ignored_controllers(controllers = nil)
      if controllers
        @apipie_ignored_controllers = controllers
        Apipie.configuration.ignored.concat(controllers)
      end
      @apipie_ignored_controllers
    end

    # register custom host status class, it should inherit from HostStatus::Status
    def register_custom_status(klass)
      in_to_prepare do
        HostStatus.status_registry.add(klass)
      end
    end

    # register a provision method
    def provision_method(name, friendly_name)
      return if @provision_methods.key?(name.to_s)
      @provision_methods[name.to_s] = friendly_name
    end

    def register_facet(klass, name, &block)
      Facets.register(klass, name, &block)
    end

    def in_to_prepare(&block)
      @to_prepare_callbacks << block
    end

    # add human readable label for plugin's template kind with i18n support: template_labels "kind_name" => N_("Nice Name")
    def template_labels(hash)
      @template_labels.merge!(hash)
    end

    def get_template_labels
      @template_labels
    end

    def parameter_filter(klass, *args, &block)
      @parameter_filters[klass.name] ||= []
      @parameter_filters[klass.name] << (block_given? ? args + [block] : args)
    end

    def parameter_filters(klass)
      @parameter_filters.fetch(klass.is_a?(Class) ? klass.name : klass, [])
    end

    def smart_proxy_for(klass, name, options)
      @smart_proxies[klass.name] ||= {}
      @smart_proxies[klass.name][name] = options
      klass.register_smart_proxy(name, options)
    end

    def smart_proxies(klass)
      @smart_proxies.fetch(klass.name, {})
    end

    private

    def extend_template_helpers_by_module(mod)
      mod = mod.constantize

      (TemplatesController.descendants + [ TemplatesController, UnattendedHelper ]).each do |klass|
        klass.send(:include, mod)
      end
      allowed_template_helpers(*(mod.public_instance_methods - Module.public_instance_methods))
    end
  end
end
