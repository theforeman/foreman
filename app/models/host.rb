module Host
  def self.method_missing(method, *args, &block)
    type = "Host::Managed"
    case method.to_s
    when /create/, 'new'
      if args.empty? || args[0].nil? # got no parameters
        # set the default type
        args = [{:type => type}]
      else # got some parameters
        args[0][:type] ||= type # adds the type if it doesn't exists
        type = args[0][:type]   # stores the type for later usage.
      end
    end
    if type.constantize.respond_to?(method, true)
      type.constantize.send(method, *args, &block)
    else
      super
    end
  end

  # the API base controller expects to call 'respond_to?' on this, which
  # this module doesn't have. So we stub it out to make that logic work for
  # the "find_by_*" classes that Rails will provide
  def self.respond_to_missing?(method, include_private = false)
    method.to_s =~ /\Afind_by_(.*)\Z/ || method.to_s.include?('create') ||
      [:reorder, :new].include?(method) || super
  end
end
