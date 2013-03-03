module Host

  def self.method_missing(method, *args, &block)
    if [:create, :new, :create!].include?(method)
      if args[0]
        args[0][:type] ||= 'Host::Managed'
      else
        args = [{:type => 'Host::Managed'}]
      end
    end
    Host::Managed.send(method,*args, &block)
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
