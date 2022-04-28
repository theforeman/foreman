module Foreman
  class Exception < ::StandardError
    def initialize(message, *params)
      @message = message
      @params = params
    end

    def self.calculate_error_code(classname, message)
      return 'ERF00-0000' if classname.nil? || message.nil?
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

    def as_json
      { message: message }.to_json
    end
  end

  class WrappedException < ::Foreman::Exception
    def initialize(wrapped_exception, message, *params)
      super(message, *params)
      @wrapped_exception = wrapped_exception
    end

    attr_reader :wrapped_exception

    def message
      super unless @wrapped_exception.present?

      cls = @wrapped_exception.class.name
      msg = @wrapped_exception.message
      super + " ([#{cls}]: #{msg})"
    end
  end

  class MultiException < ::Foreman::Exception
    attr_reader :exceptions

    def initialize(exceptions, message, *params)
      super(message, *params)
      raise "Can't create multi exception - not an array: #{exceptions}" unless exceptions.respond_to?(:to_a)
      @exceptions = exceptions.to_a.dup.freeze
    end

    def to_s
      return super if @exceptions.empty?
      super + @exceptions.map(&:message)
    end

    def as_json
      return super if @exceptions.empty?
      (JSON[super].merge errors: @exceptions.map(&:message)).to_json
    end
  end

  class FingerprintException < Foreman::Exception
    def fingerprint
      @params[0]
    end
  end

  class UsernameOrPasswordException < Foreman::Exception
  end

  class MaintenanceException < Foreman::Exception
  end

  class BMCFeatureException < Foreman::Exception
  end

  class PermissionMissingException < Foreman::Exception
  end

  class SettingValueException < Foreman::Exception
  end

  class LdapException < Foreman::WrappedException
  end

  class CyclicGraphException < ::ActiveRecord::RecordInvalid
  end

  class AssociationNotFound < ActiveRecord::RecordNotFound
  end
end
