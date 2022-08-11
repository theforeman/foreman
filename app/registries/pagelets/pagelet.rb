module Pagelets
  class Pagelet
    attr_reader :name, :partial, :priority, :opts

    def initialize(name, partial, priority, opts)
      @name = name
      @partial = partial
      @priority = priority
      @opts = opts
      @opts[:onlyif] ||= proc { true }
      @opts[:profiles] ||= []
    end

    def <=>(other)
      priority <=> other.priority
    end

    def id
      opts[:id] || 'pagelet-id-' + @name.gsub(/\s+/, "_").underscore
    end

    def method_missing(method_name, *arguments, &block)
      super
    rescue NoMethodError
      @opts[method_name]
    end

    def respond_to_missing?(method_name, include_private = false)
      true
    end
  end
end
