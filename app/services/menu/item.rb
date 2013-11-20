module Menu
  class Item < Node
    include Rails.application.routes.url_helpers
    attr_reader :name, :condition, :parent, :child_menus, :last, :html_options

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
      super @name.to_sym
    end

    def url_hash
      @url_hash ||= send("hash_for_#{name}_path")
      @url_hash.inject({}) do |h,(key,value)|
        h[key] = (value.respond_to?(:call) ? value.call : value)
        h
      end
    end

    def authorized?
      User.current.allowed_to?({
        :controller => url_hash[:controller].to_s.gsub(/::/, "_").underscore,
        :action => url_hash[:action]
      })
    rescue false
    end

  end
end