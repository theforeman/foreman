module Foreman
  module TelemetrySinks
    class MetricExporterSink
      attr_reader :counters, :gauges, :histograms

      def initialize
        @counters = []
        @gauges = []
        @histograms = []
      end

      def add_counter(name, description, instance_labels)
        @counters << [name, description, instance_labels, :counter]
      end

      def add_gauge(name, description, instance_labels)
        @gauges << [name, description, instance_labels, :gauge]
      end

      def add_histogram(name, description, instance_labels, buckets)
        @histograms << [name, description, instance_labels, :histogram, buckets]
      end

      def increment_counter(name, value, tags)
      end

      def set_gauge(name, value, tags)
      end

      def observe_histogram(name, value, tags)
      end

      def metrics
        counters + gauges + histograms
      end
    end
  end
end
