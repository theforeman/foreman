module Pagelets
  class Manager
    def initialize(page_name)
      @page_name = page_name
    end

    def add_pagelet(mountpoint, opts)
      self.class.add_pagelet(@page_name, mountpoint, opts)
    end

    class << self
      def add_pagelet(page_name, mountpoint, opts)
        handle_empty_keys_for page_name, mountpoint
        raise ::Foreman::Exception.new(N_("Cannot add pagelet to page %s without partial", page_name)) unless opts[:partial]
        raise ::Foreman::Exception.new(N_("Cannot add pagelet to page %s without mountpoint", page_name)) if mountpoint.nil?
        priority = opts[:priority] || default_pagelet_priority(page_name, mountpoint)
        pagelet = Pagelets::Pagelet.new(opts.delete(:name), opts.delete(:partial), priority, opts)
        @pagelets[page_name][mountpoint] << pagelet
      end

      def default_pagelet_priority(page_name, mountpoint)
        # We need a default priority value for the first pagelet if it is not specified
        @pagelets[page_name][mountpoint].map(&:priority).push(0).max + 100
      end

      def pagelets_at(page_name, mountpoint)
        handle_empty_keys_for page_name, mountpoint
        @pagelets[page_name][mountpoint]
      end

      def sorted_pagelets_at(page_name, mountpoint)
        pagelets_at(page_name, mountpoint).sort
      end

      private

      def handle_empty_keys_for(page_name, mountpoint)
        @pagelets ||= {}.with_indifferent_access
        @pagelets[page_name] ||= {}
        @pagelets[page_name][mountpoint] ||= []
      end
    end
  end
end
