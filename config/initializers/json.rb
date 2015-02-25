require 'json/version'
module JSON
  class << self
    def dump_in_quirks_mode(obj, anIO = nil, limit = nil)
      if anIO && limit.nil?
        an_io_obj = anIO.to_io if anIO.respond_to?(:to_io)
        unless anIO.respond_to?(:write)
          limit = anIO
          an_io_obj = nil
        end
      end
      limit ||= 0
      result = generate(obj, :allow_nan => true, :max_nesting => limit, :quirks_mode => true)
      if an_io_obj
        an_io_obj.write result
        an_io_obj
      else
        result
      end
    rescue JSON::NestingError
      raise ArgumentError, "exceed depth limit"
    end
  end
end
