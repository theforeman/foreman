module Foreman
  module Ldap
    class LdapSubscriber < ActiveSupport::LogSubscriber
      include Foreman::TelemetryHelper

      def logger
        ::Foreman::Logging.logger('ldap')
      end

      def self.define_log(action, log_name, color)
        define_method(action) do |event|
          telemetry_observe_histogram(:ldap_request_duration, event.duration)
          return unless logger.debug?
          name = '%s (%.1fms)' % [log_name, event.duration]
          debug "  #{color(name, color, true)}  [ #{yield(event.payload)} ]"
        end
      end
    end
  end
end
