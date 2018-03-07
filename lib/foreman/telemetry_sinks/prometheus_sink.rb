module Foreman::TelemetrySinks
  class PrometheusSink
    def initialize(opts = {})
      require 'prometheus/client'
      @prom = ::Prometheus::Client.registry
    end

    def add_counter(name, description, instance_labels)
      @prom.counter(name.to_sym, description)
    end

    def add_gauge(name, description, instance_labels)
      @prom.gauge(name.to_sym, description)
    end

    def add_histogram(name, description, instance_labels, buckets)
      @prom.histogram(name.to_sym, description, {}, buckets)
    end

    def increment_counter(name, value, tags)
      @prom.get(name.to_sym).increment(tags, value)
    end

    def set_gauge(name, value, tags)
      @prom.get(name.to_sym).set(tags, value)
    end

    def observe_histogram(name, value, tags)
      @prom.get(name.to_sym).observe(tags, value)
    end
  end
end
