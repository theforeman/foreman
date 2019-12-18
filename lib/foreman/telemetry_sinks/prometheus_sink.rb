module Foreman::TelemetrySinks
  class PrometheusSink
    def initialize(opts = {})
      require 'prometheus/client'
      @prom = ::Prometheus::Client.registry
    end

    def add_counter(name, description, instance_labels)
      @prom.counter(name.to_sym, docstring: description, labels: instance_labels)
    end

    def add_gauge(name, description, instance_labels)
      @prom.gauge(name.to_sym, docstring: description, labels: instance_labels)
    end

    def add_histogram(name, description, instance_labels, buckets)
      @prom.histogram(name.to_sym, docstring: description, buckets: buckets, labels: instance_labels)
    end

    def increment_counter(name, value, tags)
      @prom.get(name.to_sym).increment(by: value, labels: tags)
    end

    def set_gauge(name, value, tags)
      @prom.get(name.to_sym).set(value, labels: tags)
    end

    def observe_histogram(name, value, tags)
      @prom.get(name.to_sym).observe(value, labels: tags)
    end
  end
end
