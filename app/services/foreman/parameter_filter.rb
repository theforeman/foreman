# Stores permitted parameters for a given resource/AR model for use in
# controllers to filter input parameters.
#
# Allows the permitted parameters to be set up once model and re-used in
# multiple contexts, e.g. API controllers, UI controllers and nested UI
# attributes, by applying different rules.
#
module Foreman
  class ParameterFilter
    attr_reader :resource_class

    def initialize(resource_class)
      @resource_class = resource_class
      @parameter_filters = []

      Foreman::Plugin.all.each do |plugin|
        plugin.parameter_filters(resource_class).each do |filter|
          if filter.last.is_a?(Proc)
            *filter, filter_block = filter
            permit(*filter, &filter_block)
          else
            permit(*filter)
          end
        end
      end
    end

    # Return a list of permitted parameters that may be passed into #permit
    def filter(context)
      @parameter_filters.each { |f| context.instance_eval(&f) }
      context.permitted.map { |f| expand_nested(f, context) }
    end

    # Runs permitted parameter whitelist against supplied parameters
    #
    # top_level_hash may be set to the name of the first-level hash when
    # filtering rather than defaulting to the controller name, or :none to
    # filter first-level parameters.
    def filter_params(params, context, top_level_hash = nil)
      top_level_hash ||= context.controller_name.singularize
      if top_level_hash == :none
        params.permit(*filter(context)).to_h
      else
        if context.api? # allow both wrapped and unwrapped
          allow = [*filter(context), top_level_hash => filter(context)]
        else
          allow = {top_level_hash => filter(context)}
        end
        permitted = params.permit(allow)
        permitted.to_h.fetch(top_level_hash, {})
      end
    end

    # Registers new whitelisted parameter(s) in the same form as
    # ActionController::Parameters#permit, plus can accept a ParametersFilter
    # instance for nested models which is expanded.
    #
    # A block can be passed to determine when the parameter is permitted
    # dynamically from the Context class, else it defaults to API and UI only,
    # but not nested.
    def permit(*args, &block)
      new_filter = block_given? ? block : ->(ctx) { ctx.permit(*args) unless ctx.nested? }
      @parameter_filters << new_filter
    end

    # Last argument of a hash determines which contexts the parameter may be
    # used in, defaulting to API and UI only.
    def permit_by_context(*args, opts)
      unknown_keys = opts.keys - [:api, :nested, :ui]
      raise ArgumentError, "unknown parameter context: #{unknown_keys.join(', ')}" if unknown_keys.present?

      opts = {:api => true, :nested => false, :ui => true}.merge(opts)
      @parameter_filters << ->(context) { context.permit(*args) if opts[context.type] }
    end

    def accessible_attributes(context)
      filter(context).map do |f|
        f.is_a?(Hash) ? f.keys : f
      end.flatten.map(&:to_s)
    end

    private

    def expand_nested(filter, context)
      if filter.is_a?(ParameterFilter)
        filter.filter(Context.new(:nested, context.controller_name, context.action))
      elsif filter.is_a?(Hash)
        filter.transform_values { |v| expand_nested(v, context) }
      elsif filter.is_a?(Array)
        filter.map { |v| expand_nested(v, context) }
      else
        filter
      end
    end

    # Public API for blocks passed into #permit, allowing them to inspect the
    # context of the request and permit/deny different parameters
    class Context
      attr_reader :permitted, :type, :controller_name, :action

      def initialize(type, controller_name, action)
        @type = type
        @permitted = []
        @controller_name = controller_name
        @action = action
      end

      def api?
        @type == :api
      end

      def nested?
        @type == :nested
      end

      def ui?
        @type == :ui
      end

      # Accepts same arguments as ActionController::Parameters#permit, plus can
      # accept a ParametersFilter instance for nested models which is expanded
      def permit(*args)
        @permitted.push(*args)
      end
    end
  end
end
