require 'singleton'
require 'forwardable'

module Foreman
  class Telemetry
    include Singleton
    extend Forwardable
    attr_accessor :prefix, :sinks

    DEFAULT_BUCKETS = [10, 50, 200, 1000, 15000].freeze

    def initialize
      @sinks = []
      @exporter = ::Foreman::TelemetrySinks::MetricExporterSink.new
    end

    def setup(opts = {})
      @prefix = opts[:prefix] || ''
      @sinks << @exporter
      unless Foreman.in_rake?
        @sinks << ::Foreman::TelemetrySinks::RailsLoggerSink.new(opts[:logger]) if opts[:logger] && opts[:logger][:enabled]
        @sinks << ::Foreman::TelemetrySinks::PrometheusSink.new(opts[:prometheus]) if opts[:prometheus] && opts[:prometheus][:enabled]
        @sinks << ::Foreman::TelemetrySinks::StatsdSink.new(opts[:statsd]) if opts[:statsd] && opts[:statsd][:enabled]
      end
      self
    end

    GC_METRICS = {
      :count => :ruby_gc_count,
      :major_gc_count => :ruby_gc_major_count,
      :minor_gc_count => :ruby_gc_minor_count
    }
    def register_rails
      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        controller = event.payload[:controller].underscore
        action = event.payload[:action].underscore
        status = event.payload[:status]

        increment_counter(:http_requests, 1, :controller => controller, :action => action, :status => status)
        observe_histogram(:http_request_total_duration, event.duration || 0, :controller => controller, :action => action)
        observe_histogram(:http_request_db_duration, event.payload[:db_runtime] || 0, :controller => controller, :action => action)
        observe_histogram(:http_request_view_duration, event.payload[:view_runtime] || 0, :controller => controller, :action => action)

        # measure GC stats for each request
        before = Thread.current[:foreman_telemetry_gcstats]
        after = GC.stat
        GC_METRICS.each do |ruby_key, metric_name|
          increment_counter(metric_name, after[ruby_key] - before[ruby_key], :controller => controller, :action => action) if after.include?(ruby_key)
        end if before
      end if enabled?

      ActiveSupport::Notifications.subscribe(/instantiation.active_record/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        class_name = event.payload[:class_name]
        record_count = event.payload[:record_count]
        increment_counter(:activerecord_instances, record_count, :class => class_name)
      end if enabled?
    end

    def register_ruby
      begin
        GC.stat :total_allocated_objects
      rescue ArgumentError
        GC_METRICS.update :total_allocated_object => :ruby_gc_allocated_objects, :total_freed_object => :ruby_gc_freed_objects
      else
        GC_METRICS.update :total_allocated_objects => :ruby_gc_allocated_objects, :total_freed_objects => :ruby_gc_freed_objects
      end
      GC_METRICS.each do |ruby_key, metric_name|
        add_counter(metric_name, "Ruby GC statistics per request (#{ruby_key})", [:controller, :action])
      end
    end

    def metrics
      @exporter.metrics
    end

    def enabled?
      @sinks.count > 0
    end

    def add_counter(name, description, instance_labels = [])
      @sinks.each { |x| x.add_counter("#{prefix}_#{name}", description, instance_labels) }
    end

    def add_gauge(name, description, instance_labels = [])
      @sinks.each { |x| x.add_gauge("#{prefix}_#{name}", description, instance_labels) }
    end

    def add_histogram(name, description, instance_labels = [], buckets = DEFAULT_BUCKETS)
      @sinks.each { |x| x.add_histogram("#{prefix}_#{name}", description, instance_labels, buckets) }
    end

    def increment_counter(name, value = 1, tags = {})
      @sinks.each { |x| x.increment_counter("#{prefix}_#{name}", value, tags) }
    end

    def set_gauge(name, value, tags = {})
      @sinks.each { |x| x.set_gauge("#{prefix}_#{name}", value, tags) }
    end

    def observe_histogram(name, value, tags = {})
      @sinks.each { |x| x.observe_histogram("#{prefix}_#{name}", value, tags) }
    end
  end
end
