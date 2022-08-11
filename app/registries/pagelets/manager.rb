module Pagelets
  class Manager
    DEFAULT_PARTIALS = {
      hosts_table_column_header: 'common/selectable_column_th',
      hosts_table_column_content: 'common/selectable_column_td',
    }.freeze

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
      partial = opts.delete(:partial) || default_pagelet_partial(mountpoint)
      raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without partial"), key) unless partial
      raise ::Foreman::Exception.new(N_("Cannot add pagelet with key %s and without mountpoint"), key) if mountpoint.nil?
      priority = opts[:priority] || default_pagelet_priority(key, mountpoint)
      pagelet = Pagelets::Pagelet.new(opts.delete(:name), partial, priority, opts)
      @pagelets[key][mountpoint] << pagelet
      pagelet
    end

    def clear
      @pagelets.clear
    end

    def pagelets_at(key, mountpoint, opts = {})
      handle_empty_keys_for key, mountpoint
      pagelets = @pagelets[key][mountpoint]
      return pagelets unless opts[:filter]

      Pagelets::Filter.new(pagelets).filter(opts[:filter])
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

      def with_profile(id, label, opts, &block)
        profile = Profile.new(id, label, self, opts)
        profile.instance_exec(&block)
        profile.pagelets.each do |pagelet|
          add_pagelet(*pagelet)
        end
      end
    end

    class Profile
      attr_reader :id, :label, :opts, :pagelets

      def initialize(id, label, context, opts)
        @id = id
        @label = label
        @context = context
        @opts = opts
        @pagelets = []
      end

      def default?
        @opts[:default]
      end

      def add_pagelet(mountpoint, opts)
        opts = opts.merge(profiles: [self])
        @pagelets << [mountpoint, opts]
      end

      def use_pagelet(mountpoint, key)
        pagelet = @context.pagelets_at(mountpoint).find { |pt| pt.key == key }
        raise ::Foreman::Exception.new(N_("Pagelet with %s key is not found"), key) unless pagelet

        pagelet.profiles.push(self)
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

    def default_pagelet_partial(mountpoint)
      DEFAULT_PARTIALS[mountpoint]
    end
  end
end
