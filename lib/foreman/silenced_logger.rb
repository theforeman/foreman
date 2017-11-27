# Wrap a ::Logging::Logger and implement #silence to temporarily increase the
# min log level to execute a block of code. Used by sprockets-rails' quiet
# assets logging feature.
module Foreman
  class SilencedLogger < SimpleDelegator
    # Allow webpack to run logger.tagged
    def tagged(*tags)
      yield self
    end

    def silence(new_level = Logger::ERROR, &block)
      old_level = self.level
      begin
        self.level = new_level
        yield self
      ensure
        self.level = old_level
      end
    end
  end
end
