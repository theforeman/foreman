require 'resolv'

class MemoizedResolver
  def initialize
    @query_cache ||= {}
    @resolver ||= Resolv.new
  end

  def each_address(name, &blk)
    @resolver.each_address(name, &blk)
  end

  def each_name(address, &blk)
    @resolver.each_name(address, &blk)
  end

  [:getaddress, :getaddressses, :getname, :getnames].each do |method|
    define_method(method) do |name|
      unless @query_cache.key?("#{method}#{name}")
        @query_cache["#{method}#{name}"] = @resolver.send(method, name)
      end
      @query_cache["#{method}#{name}"]
    end
  end
end
