class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options.has_key?(:default) ? options[:default] : false
  end

  def matches?(req)
    route_match       = req.fullpath.match(%r{/api/v(\d+)}) if req.fullpath
    header_match      = req.accept.match(%r{version=(\d+)}) if req.accept

    return (@version.to_s == route_match[1]) if route_match
    return (@version.to_s == header_match[1]) if header_match
    # if version is not specified in route or header, then it returns true only if :default => true in routes file v1.rb or v2.rb
    @default
  end
end
