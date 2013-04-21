module Foreman

  class Exception < ::StandardError
    def initialize message, *params
      @message = message
      @params = params
    end

    # Error code is made up first 8 characters of base64 (RFC 4648) encoded MD5
    # sum of concatenated classname and message
    def self.calculate_error_code classname, message
      "ERF-" + [Digest::MD5.digest("#{classname}#{message}")].pack('m0')[0..8]
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
  end

end
