module Foreman

  class Exception < ::StandardError
    def initialize message, *params
      @message = message
      @params = params
    end

    # Error code is made up first 8 characters of base64 (RFC 4648) encoded MD5
    # sum of concatenated classname and message
    def self.calculate_error_code classname, message
      class_hash = Zlib::crc32(classname) % 100
      msg_hash = Zlib::crc32(message) % 10000
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
        translated_msg = @message
      end
      "#{code}: #{translated_msg}"
    end

    alias :to_s :message
  end

end
