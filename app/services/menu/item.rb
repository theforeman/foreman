module Menu
  class Item < Node
    include Menu::IsolatedRoutes
    include Rails.application.routes.url_helpers
    attr_reader :name, :condition, :parent, :child_menus, :last, :html_options, :engine_name, :url_hash

    def initialize(name, options)
      raise ArgumentError, "Invalid option :if for menu item '#{name}'" if options[:if] && !options[:if].respond_to?(:call)
      raise ArgumentError, "Invalid option :html for menu item '#{name}'" if options[:html] && !options[:html].is_a?(Hash)
      raise ArgumentError, "Cannot set the :parent to be the same as this item" if options[:parent] == name.to_sym
      raise ArgumentError, "Invalid option :children for menu item '#{name}'" if options[:children] && !options[:children].respond_to?(:call)
      @name = name
      @url_hash = options[:url_hash]
      @condition = options[:if]
      @caption = options[:caption]
      @html_options = options[:html] || {}
      @parent = options[:parent]
      @child_menus = options[:children]
      @last = options[:last] || false
      @engine_name = options[:engine_name]
      super @name.to_sym
    end

    def path_hash
      path_hash   = @url_hash
      path_hash ||= send(engine_name).send("hash_for_#{name}_path") if engine_name
      path_hash ||= send("hash_for_#{name}_path")
      path_hash.inject({}) do |h,(key,value)|
        h[key] = (value.respond_to?(:call) ? value.call : value)
        h
      end
    end

    def url_from_name
      return send(engine_name).send("#{name}_path") if engine_name && !@url_hash
      send("#{name}_path") if !@url_hash
    end

    def url_from_hash(p = path_hash)
      p.merge!(:only_path => true)
      return send(engine_name).url_for(p) if engine_name
      url_for(p)
    end

    def url
      url_from_name || url_from_hash
    end

    def authorized?
      User.current.allowed_to?({
        :controller => path_hash[:controller].to_s.gsub(/::/, "_").underscore,
        :action => path_hash[:action]
      })
    rescue
      false
    end

  end
end