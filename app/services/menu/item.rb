module Menu
  class Item < Node
    attr_reader :name, :condition, :parent, :child_menus, :last, :html_options, :turbolinks

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
      @turbolinks = options.fetch(:turbolinks, true)
      super @name.to_sym
    end

    def url
      add_relative_path(@url || @context.routes.url_for(url_hash.merge(:only_path=>true)))
    end

    def url_hash
      @url_hash ||= @context.routes.url_helpers.send("hash_for_#{name}_path")
      @url_hash.inject({}) do |h,(key,value)|
        h[key] = (value.respond_to?(:call) ? value.call : value)
        h
      end
    end

    def authorized?
      User.current.allowed_to?(url_hash.slice(:controller, :action, :id))
    rescue => error
      Rails.logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      false
    end

    private

    def add_relative_path(path)
      rurl = @context.config.action_controller.relative_url_root
      rurl.present? && !path.start_with?(rurl.end_with?('/') ? rurl : "#{rurl}/") ? "#{rurl}#{path}" : path
    end
  end
end
