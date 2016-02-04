module Foreman
  class Exception < ::StandardError
    def initialize(message, *params)
      @message = message
      @params = params
    end

    def self.calculate_error_code(classname, message)
      return 'ERF00-0000' if classname.nil? or message.nil?
      basename = classname.split(':').last
      class_hash = Zlib.crc32(basename) % 100
      msg_hash = Zlib.crc32(message) % 10000
      sprintf "ERF%02d-%04d", class_hash, msg_hash
    end

    def code
      @code ||= Exception.calculate_error_code self.class.name, @message
      @code
    end

    def message_untranslated
      @message
    end

    def message
      # make sure it works without gettext too
      if Kernel.respond_to? :_
        translated_msg = _(@message) % @params
      else
        # use plain ruby interpolation
        translated_msg = @message % @params
      end
      "#{code} [#{self.class.name}]: #{translated_msg}"
    end

    def to_s
      message
    end
  end

  class FingerprintException < Exception
    def fingerprint
      @params[0]
    end
  end

  class CyclicGraphException < ::ActiveRecord::RecordInvalid
  end
end
