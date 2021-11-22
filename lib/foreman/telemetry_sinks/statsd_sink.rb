module Foreman
  module TelemetrySinks
    class StatsdSink
      def initialize(opts = {})
        require 'statsd-instrument'
        @instances = {}
        host = opts[:host] || '127.0.0.1:8125'
        @protocol = opts[:protocol].try(:to_sym) || :statsite
        StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new(host, @protocol)
      end

      def add_counter(name, description, instance_labels)
        raise ::Foreman::Exception.new(N_('Metric already registered: %s'), name) if @instances[name]
        @instances[name] = instance_labels
      end

      def add_gauge(name, description, instance_labels)
        raise ::Foreman::Exception.new(N_('Metric already registered: %s'), name) if @instances[name]
        @instances[name] = instance_labels
      end

      def add_histogram(name, description, instance_labels, buckets)
        raise ::Foreman::Exception.new(N_('Metric already registered: %s'), name) if @instances[name]
        @instances[name] = instance_labels
      end

      def increment_counter(name, value, tags)
        if @protocol == :datadog
          StatsD.increment(name, value, tags: tags_in_statsd(tags))
        else
          StatsD.increment(name_tag_mapping(name, tags), value)
        end
      end

      def set_gauge(name, value, tags)
        if @protocol == :datadog
          StatsD.gauge(name, value, tags: tags_in_statsd(tags))
        else
          StatsD.gauge(name_tag_mapping(name, tags), value)
        end
      end

      def observe_histogram(name, value, tags)
        if @protocol == :datadog
          StatsD.measure(name, value, tags: tags_in_statsd(tags))
        else
          StatsD.measure(name_tag_mapping(name, tags), value)
        end
      end

      private

      def name_tag_mapping(name, tags)
        insts = @instances[name]
        return name if insts.blank?
        (name.to_s + '.' + insts.map { |x| tags[x] }.compact.join('.')).tr('-:/ ', '____')
      end

      def tags_in_statsd(tags)
        result = []
        tags.each_pair do |name, value|
          result << "#{name}:#{value.to_s.tr('-:/ ', '____')}"
        end
        result
      end
    end
  end
end
