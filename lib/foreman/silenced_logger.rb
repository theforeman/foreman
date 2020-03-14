# Wrap a ::Logging::Logger and implement #silence to temporarily increase the
# min log level to execute a block of code. Used by sprockets-rails' quiet
# assets logging feature. Foreman uses logging gem instead Rails logging stack
# and it does not provide silencing feature (ships with just a noop method).
# This implementation only works with Logging gem, not with Ruby/Rails Logger.
#
# Inspired by lib/active_record/session_store/extension/logger_silencer.rb
#
module Foreman
  class SilencedLogger < SimpleDelegator
    ::Logging::LEVELS.each do |name, num|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{name.downcase}?
          #{num} >= local_level
        end

        def #{name.downcase}(*args)
          super(*args) if #{num} >= local_level
        end
      EOT
    end

    def level_key
      @level_key ||= :"SilencedLogger##{object_id}@level"
    end

    def local_level
      Thread.current[level_key] || level
    end

    def local_level=(level)
      Thread.current[level_key] = level
    end

    def silence(temporary_level = Logger::ERROR, &block)
      self.local_level = temporary_level
      yield self
    ensure
      self.local_level = nil
    end
    alias_method :silence_logger, :silence
  end
end
