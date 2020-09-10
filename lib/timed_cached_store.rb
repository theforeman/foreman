# A cache store implementation which stores everything into memory.
# it keeps a time stamp, allowing auto expiry of objects
# it has a similar behaviour to memcached, but does not require memcache
# however this will not clean up automatically, only upon request

class TimedCachedStore < ActiveSupport::Cache::MemoryStore
  def exist?(name, options = nil)
    delete_if_expired name
    super
  end

  def read(name)
    delete_if_expired name
    super
  end

  def write(name, value, options = nil)
    if options && options[:expires_in]
      time                  = Time.now.utc
      ttl                   = time + options[:expires_in].to_i
      @data[ts_field(name)] = { :created_at => time, :expires_at => ttl }
    end
    super
  end

  def delete_all_expired
    @data.keys.each do |key|
      delete_if_expired(Regexp.last_match(1)) if key =~ /(\w+)_timestamp/
    end
  end

  protected

  def delete_if_expired(name)
    if expired?(name)
      @data[ts_field(name)] = nil
      delete(name)
    end
  rescue
    nil
  end

  def expired?(name)
    ts = @data[ts_field(name)]
    ts && (Time.now.utc >= ts[:expires_at])
  rescue
    false
  end

  def ts_field(name)
    "#{name}_timestamp"
  end
end
