module Pagelets
  class Manager
    class << self
      delegate :add_pagelet, :pagelets_at, :with_key, to: :instance

      def instance
        @instance ||= new
      end
      attr_writer :instance
    end

    def initialize
      @pagelets = {}.with_indifferent_access
    end

    def initialize_copy(orig)
      super
      @pagelets = @pagelets.deep_dup
    end

    def add_pagelet(key, mountpoint, opts)
      handle_empty_keys_for key, mountpoint
      raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without partial"), key) unless opts[:partial]
      raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without mountpoint"), key) if mountpoint.nil?
      priority = opts[:priority] || default_pagelet_priority(key, mountpoint)
      pagelet = Pagelets::Pagelet.new(opts.delete(:name), opts.delete(:partial), priority, opts)
      @pagelets[key][mountpoint] << pagelet
      pagelet
    end

    def clear
      @pagelets.clear
    end

    def pagelets_at(key, mountpoint)
      handle_empty_keys_for key, mountpoint
      @pagelets[key][mountpoint]
    end

    # Yields a simpler interface for add_pagelet to avoid re-stating the key
    def with_key(key, &block)
      yield KeyContext.new(self, key)
    end

    class KeyContext
      def initialize(manager, key)
        @manager = manager
        @key = key
      end

      def add_pagelet(*args)
        @manager.add_pagelet(*args.unshift(@key))
      end

      def pagelets_at(*args)
        @manager.pagelets_at(*args.unshift(@key))
      end
    end

    private

    def handle_empty_keys_for(key, mountpoint)
      @pagelets[key] ||= {}
      @pagelets[key][mountpoint] ||= []
    end

    def default_pagelet_priority(key, mountpoint)
      # We need a default priority value for the first pagelet if it is not specified
      @pagelets[key][mountpoint].map(&:priority).push(0).max + 100
    end
  end
end
