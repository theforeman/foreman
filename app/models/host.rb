module Host
  def self.method_missing(method, *args, **kwargs, &block)
    type = "Host::Managed"
    case method.to_s
    when /create/, 'new'
      # in this case args should contain a hash with host attributes
      if (args.empty? || args[0].nil?) && kwargs.empty? # got no parameters
        # set the default type
        args = [{:type => type}]
      else # got some parameters
        type = args.first&.dig(:type) || kwargs[:type] || type
      end
      attrs = kwargs.merge(args.first || { type: type })
      # quick skip for simple cases
      # expects and follows default signature: def new(attributes = nil, &block)
      type.constantize.send(method, attrs, &block)
    else
      klass = type.constantize
      if klass.respond_to?(method, true)
        # Removing block, since we will pass it anyway
        meth_params = klass.method(method).parameters.collect { |par_desc| par_desc.first } - [:block]
        if meth_params.empty? || (args.empty? && kwargs.empty?)
          klass.send(method, &block)
        elsif meth_params == [:rest]
          # means that the method could accept anything, e.g. def find_by(*args),
          # but internally would expect a Hash wrapped by *args array
          # or there are cases like Array#last, which has * as param list, but expects an Integer
          # since there is a lot of delegation in Rails, it's hard to know exact signature of the real method:
          # find_in_batches expects only kwargs, but method(:find_in_batces) returns (*) as param list
          # through the same delegation goes find_by with a different signature/expectations

          if !args.empty?
            klass.send(method, *args, &block)
          elsif kwargs.any?
            klass.send(method, **kwargs, &block)
            # here should probably be a closing "else" for other cases
          end
        elsif (meth_params & [:req, :opt, :rest]).empty?
          # this would mean we pass kwargs only
          klass.send(method, **kwargs, &block)
        elsif (meth_params & [:key, :keyreq, :keyrest]).empty?
          # if there is no kwargs, let's treat this as before
          klass.send(method, *args, &block)
        else
          # let's treat as we should
          klass.send(method, *args, **kwargs, &block)
        end
      else
        super
      end
    end
  end

  # the API base controller expects to call 'respond_to?' on this, which
  # this module doesn't have. So we stub it out to make that logic work for
  # the "find_by_*" classes that Rails will provide
  def self.respond_to_missing?(method, include_private = false)
    method.to_s =~ /\Afind_by_(.*)\Z/ || method.to_s.include?('create') ||
      [:reorder, :new].include?(method) || super
  end

  # This is a workaround for https://github.com/rails/rails/blob/v7.0.4/activerecord/lib/active_record/reflection.rb#L420-L443
  def self.<(other)
    other == ActiveRecord::Base || super
  end
end
