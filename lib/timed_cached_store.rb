# A cache store implementation which stores everything into memory.
# it keeps a time stamp, allowing auto expiry of objects
# it has a similar behaviour to memcached, but does not require memcache
# however this will not clean up automatically, only upon request

class TimedCachedStore < ActiveSupport::Cache::SynchronizedMemoryStore
  def exist?(name, options = nil)
    delete_if_expired name
    super
  end

  def read(name)
    delete_if_expired name
    super
  end

  def write(name, value, options = nil)
    if options and options[:expires_in]
      time                  = Time.now
      ttl                   = time + options[:expires_in].to_i
      @data[ts_field(name)] = { :created_at => time, :expires_at => ttl }
    end
    super
  end

  def delete_all_expired
    @data.keys.each do |key|
      if key =~ /(\w+)_timestamp/
        delete_if_expired($1)
      end
    end
  end

  protected
  def delete_if_expired name
    if expired?(name)
      @data[ts_field(name)] = nil
      delete(name)
    end
  rescue
    nil
  end

  def expired? name
    ts = @data[ts_field(name)]
    ts and (Time.now >= ts[:expires_at])
  rescue
    false
  end

  def ts_field name
    "#{name}_timestamp"
  end

end