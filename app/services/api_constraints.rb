class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options.has_key?(:default) ? options[:default] : false
  end

  def matches?(req)
    route_match = req.fullpath.match(%r{/api/v(\d+)}) if req.fullpath

    return (@version.to_s == route_match[1]) if route_match
    # if version is not specified in route, then it returns true only if :default => true in routes
    @default
  end
end
