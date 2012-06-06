class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].each {|h| return true if h.grep("version=#{@version}")}
  end
end
