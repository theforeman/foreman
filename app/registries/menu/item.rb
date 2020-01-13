module Menu
  class Item < Node
    attr_reader :name, :condition, :parent, :child_menus, :last, :html_options

    def initialize(name, options)
      raise ArgumentError, "Invalid option :if for menu item '#{name}'" if options[:if] && !options[:if].respond_to?(:call)
      raise ArgumentError, "Invalid option :engine for menu item '#{name}'" if options[:engine] && !options[:engine].respond_to?(:routes)
      raise ArgumentError, "Invalid option :html for menu item '#{name}'" if options[:html] && !options[:html].is_a?(Hash)
      raise ArgumentError, "Cannot set the :parent to be the same as this item" if options[:parent] == name.to_sym
      raise ArgumentError, "Invalid option :children for menu item '#{name}'" if options[:children] && !options[:children].respond_to?(:call)
      @name = name
      @url = options[:url]
      @url_hash = options[:url_hash]
      @condition = options[:if]
      @caption = options[:caption]
      @html_options = options[:html] || {}
      @parent = options[:parent]
      @child_menus = options[:children]
      @last = options[:last] || false
      @context =  options[:engine] || Rails.application
      @exact = options[:exact] || false
      super @name.to_sym
    end

    def to_hash
      {type: :item, exact: @exact, html_options: @html_options, name: @caption || @name, url: url} if authorized?
    end

    def url
      add_relative_path(@url || @context.routes.url_for(url_hash.merge(:only_path => true).except(:use_route)))
    end

    def url_hash
      @url_hash ||= @context.routes.url_helpers.send("hash_for_#{name}_path")
      @url_hash.each_with_object({}) do |(key, value), h|
        h[key] = (value.respond_to?(:call) ? value.call : value)
      end
    end

    def authorized?
      User.current.allowed_to?(url_hash.slice(:controller, :action, :id))
    rescue => error
      Foreman::Logging.exception("Error while evaluating permissions", error)
      false
    end

    private

    def add_relative_path(path)
      relative_url = @context.config.action_controller.relative_url_root
      return path unless relative_url.present?
      return "#{relative_url}#{path}" unless path.start_with?(relative_url.end_with?('/') ? relative_url : "#{relative_url}/")
      path
    end
  end
end
