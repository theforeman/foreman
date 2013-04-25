class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options.has_key?(:default) ? options[:default] : false
  end

  def matches?(req)
    req.accept =~ /version=([\d\.]+)/
    if (version = $1) # version is specified in header
      version == @version.to_s # are the versions same
    else
      @default # version is not specified, match if it's default version of api
    end
  end
end
