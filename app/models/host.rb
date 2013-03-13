module Host

  def self.method_missing(method, *args, &block)
    type = "Host::Managed"
    case method.to_s
    when /create/, 'new'
      if args.empty? or args[0].nil? # got no parameters
        #set the default type
        args = [{:type => type}]
      else # got some parameters
        args[0][:type] ||= type # adds the type if it doesnt exists
        type = args[0][:type]   # stores the type for later usage.
      end
    end

    type.constantize.send(method,*args, &block)
  end

  # the API base controller expects to call 'respond_to?' on this, which
  # this module doesn't have. So we stub it out to make that logic work for
  # the "find_by_*" classes that Rails will provide
  def self.respond_to?(method, include_private = false)
    if method.to_s =~ /^find_by_(.*)$/
      true
    else
      super
    end
  end

end
