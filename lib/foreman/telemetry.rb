require 'singleton'
require 'forwardable'

require 'foreman/telemetry_sinks/metric_exporter_sink'
require 'foreman/telemetry_sinks/prometheus_sink'
require 'foreman/telemetry_sinks/rails_logger_sink'
require 'foreman/telemetry_sinks/statsd_sink'

module Foreman
  class Telemetry
    include Singleton
    extend Forwardable
    attr_accessor :prefix, :sinks

    DEFAULT_BUCKETS = [100, 500, 3000].freeze

    def initialize
      @sinks = []
      @exporter = ::Foreman::TelemetrySinks::MetricExporterSink.new
      @allowed_tags = {}
    end

    def setup(opts = {})
      @prefix = opts[:prefix] || ''
      @sinks << @exporter
      unless Foreman.in_rake?
        setup_sink(:logger, opts, ::Foreman::TelemetrySinks::RailsLoggerSink)
        setup_sink(:prometheus, opts, ::Foreman::TelemetrySinks::PrometheusSink)
        setup_sink(:statsd, opts, ::Foreman::TelemetrySinks::StatsdSink)
      end
      self
    end

    def setup_sink(name, opts, impl)
      @sinks << impl.new(opts[name]) if opts[name] && opts[name][:enabled]
    rescue LoadError => ex
      Rails.logger.warn "Unable to initialize #{name} telemetry: #{ex}"
    rescue KeyError
      # not configured
    end

    GC_METRICS = {
      :count => :ruby_gc_count,
      :major_gc_count => :ruby_gc_major_count,
      :minor_gc_count => :ruby_gc_minor_count,
    }
    def register_rails
      if enabled?
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
          if before
            GC_METRICS.each do |ruby_key, metric_name|
              if after.include?(ruby_key)
                count = after[ruby_key] - before[ruby_key]
                increment_counter(metric_name, count, :controller => controller, :action => action) if count > 0
              end
            end
          end
        end
      end

      if enabled?
        ActiveSupport::Notifications.subscribe(/instantiation.active_record/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          class_name = event.payload[:class_name]
          record_count = event.payload[:record_count]
          increment_counter(:activerecord_instances, record_count, :class => class_name) if record_count > 0
        end
      end
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
      @sinks.count > 1
    end

    def add_allowed_tags!(labels)
      labels.each do |k, v|
        @allowed_tags[k] = Regexp.compile('^(' + v.join('|') + ')$')
      end
      @allowed_tags
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
      return unless allowed?(tags)
      @sinks.each { |x| x.increment_counter("#{prefix}_#{name}", value, tags) }
    end

    def set_gauge(name, value, tags = {})
      return unless allowed?(tags)
      @sinks.each { |x| x.set_gauge("#{prefix}_#{name}", value, tags) }
    end

    def observe_histogram(name, value, tags = {})
      return unless allowed?(tags)
      @sinks.each { |x| x.observe_histogram("#{prefix}_#{name}", value, tags) }
    end

    private

    def allowed?(tags)
      result = true
      tags.each do |label, value|
        regexp = @allowed_tags[label]
        result &&= !!regexp.match(value) if regexp
      end
      result
    end
  end
end
