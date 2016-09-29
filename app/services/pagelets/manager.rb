module Pagelets
  class Manager
    def initialize(key)
      @key = key
    end

    def add_pagelet(mountpoint, opts)
      self.class.add_pagelet(@key, mountpoint, opts)
    end

    class << self
      def add_pagelet(key, mountpoint, opts)
        handle_empty_keys_for key, mountpoint
        raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without partial"), key) unless opts[:partial]
        raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without mountpoint"), key) if mountpoint.nil?
        priority = opts[:priority] || default_pagelet_priority(key, mountpoint)
        pagelet = Pagelets::Pagelet.new(opts.delete(:name), opts.delete(:partial), priority, opts)
        @pagelets[key][mountpoint] << pagelet
      end

      def default_pagelet_priority(key, mountpoint)
        # We need a default priority value for the first pagelet if it is not specified
        @pagelets[key][mountpoint].map(&:priority).push(0).max + 100
      end

      def pagelets_at(key, mountpoint)
        handle_empty_keys_for key, mountpoint
        @pagelets[key][mountpoint]
      end

      def clear
        @pagelets.clear
      end

      private

      def handle_empty_keys_for(key, mountpoint)
        @pagelets ||= {}.with_indifferent_access
        @pagelets[key] ||= {}
        @pagelets[key][mountpoint] ||= []
      end
    end
  end
end
