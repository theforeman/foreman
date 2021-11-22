module Foreman
  module TelemetrySinks
    class RailsLoggerSink
      def initialize(opts = {})
        @logger = Foreman::Logging.logger('telemetry')
        @level = Logger.const_get(opts[:level].try(:to_sym).try(:upcase) || :debug)
      end

      def add_counter(name, description, instance_labels)
        @logger.add(@level, "Registering counter #{name} labels #{instance_labels.inspect}")
      end

      def add_gauge(name, description, instance_labels)
        @logger.add(@level, "Registering gauge #{name} labels #{instance_labels.inspect}")
      end

      def add_histogram(name, description, instance_labels, ignored)
        @logger.add(@level, "Registering histogram #{name} labels #{instance_labels.inspect}")
      end

      def increment_counter(name, value, tags)
        @logger.add(@level, "Incrementing counter #{name} by #{sprintf('%0.02f', value)} #{tags.inspect}")
      end

      def set_gauge(name, value, tags)
        @logger.add(@level, "Setting gauge #{name} to #{sprintf('%0.02f', value)} #{tags.inspect}")
      end

      def observe_histogram(name, value, tags)
        @logger.add(@level, "Observing histogram #{name} value #{sprintf('%0.02f', value)} #{tags.inspect}")
      end
    end
  end
end
