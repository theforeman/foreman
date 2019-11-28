require 'logging'
require 'fileutils'

module Foreman
  class LoggingImpl
    private_class_method :new

    attr_reader :config, :log_directory

    def configure(options = {})
      fail 'logging can be configured only once' if @configured
      @configured = true

      @log_directory = options.fetch(:log_directory, './log')
      ensure_log_directory(@log_directory)

      load_config(options.fetch(:environment), options.fetch(:config_overrides, {}))

      # override via Rails env var
      @config[:type] = 'stdout' if ENV['RAILS_LOG_TO_STDOUT']

      configure_color_scheme
      configure_root_logger(options)
      add_console_appender if @config[:console_inline]

      # we need to postpone loading of the silenced logger
      # to the time the Logging::LEVELS is initialized
      require_dependency File.expand_path('silenced_logger', __dir__)
    end

    def add_loggers(loggers = {})
      return unless loggers.is_a?(Hash)

      loggers.each do |name, config|
        add_logger(name, config)
      end
    end

    def add_logger(logger_name, logger_config)
      logger = ::Logging.logger[logger_name]
      if logger_config.key?(:enabled)
        if logger_config[:enabled]
          logger.additive = true
          logger.level = logger_config[:level] if logger_config.key?(:level)
        else
          # set high level for disabled logger
          logger.level = :fatal
        end
      end

      # TODO: Remove once only Logging 2.0 is supported
      if logger.respond_to?(:caller_tracing)
        logger.caller_tracing = logger_config[:log_trace] || @config[:log_trace]
      else
        logger.trace = logger_config[:log_trace] || @config[:log_trace]
      end
    end

    def loggers
      ::Logging::Repository.instance.children('root').map(&:name)
    end

    def logger(name)
      return Foreman::SilencedLogger.new(::Logging.logger[name]) if ::Logging::Repository.instance.has_logger?(name)
      fail "Trying to use logger #{name} which has not been configured."
    end

    def logger_level(name)
      level_int = logger(name).level
      ::Logging::LEVELS.find { |n, i| i == level_int }.first
    end

    # Structured fields to log in addition to log messages. Every log line created within given block is enriched with these fields.
    # Fields appear in joruand and/or JSON output (hash named 'ndc').
    def with_fields(fields = {})
      ::Logging.ndc.push(fields) do
        yield
      end
    end

    # Standard way for logging exceptions to get the most data in the log.
    # The behaviour can be influenced by this options:
    #   * :logger - the name of the logger to put the exception in ('app' by default)
    #   * :level - the logging level (:warn by default)
    def exception(context_message, exception, options = {})
      options.assert_valid_keys :level, :logger
      logger_name = options[:logger] || 'app'
      level = options[:level] || :warn
      backtrace_level = options[:backtrace_level] || :info
      unless ::Logging::LEVELS.key?(level.to_s)
        raise "Unexpected log level #{level}, expected one of #{::Logging::LEVELS.keys}"
      end
      # send class, message and stack as structured fields in addition to message string
      backtrace = exception.backtrace || []
      extra_fields = {
        exception_class: exception.class.name,
        exception_message: exception.message,
        exception_backtrace: backtrace,
      }
      extra_fields[:foreman_code] = exception.code if exception.respond_to?(:code)
      with_fields(extra_fields) do
        logger(logger_name).public_send(level) { context_message }
      end
      # backtrace have its own separate level to prevent flooding logs with backtraces
      logger(logger_name).public_send(backtrace_level) do
        "Backtrace for '#{context_message}' error (#{exception.class}): #{exception.message}\n" + backtrace.join("\n")
      end
    end

    def blob(message, contents, extra_fields = {})
      logger_name = extra_fields[:logger] || 'blob'
      with_fields(extra_fields) do
        logger(logger_name).info do
          message + "\n" + contents
        end
      end
      contents
    end

    private

    def load_config(environment, overrides = {})
      fail "Logging configuration 'config/logging.yaml' not present" unless File.exist?('config/logging.yaml')
      overrides ||= {}
      overrides.deep_merge!(overrides[environment.to_sym]) if overrides.has_key?(environment.to_sym)
      @config = YAML.load_file('config/logging.yaml')
      @config = @config[:default].deep_merge(@config[environment.to_sym]).deep_merge(overrides)
    end

    def ensure_log_directory(log_directory)
      return true if File.directory?(log_directory)

      begin
        FileUtils.mkdir_p(log_directory)
      rescue Errno::EACCES
        warn "Insufficient privileges for #{log_directory}"
      end
    end

    # we also set fallback appender to STDOUT in case a developer asks for unusable appender
    def configure_root_logger(options)
      ::Logging.logger.root.level     = @config[:level]
      ::Logging.logger.root.appenders = build_root_appender(options)

      # TODO: Remove once only Logging 2.0 is supported
      if ::Logging.logger.root.respond_to?(:caller_tracing)
        ::Logging.logger.root.caller_tracing = @config[:log_trace]
      else
        ::Logging.logger.root.trace = @config[:log_trace]
      end

      # fallback to log to STDOUT if there is any @config problem
      if ::Logging.logger.root.appenders.empty?
        ::Logging.logger.root.appenders = ::Logging.appenders.stdout
        ::Logging.logger.root.warn 'No appender set, logging to STDOUT'
      end
    end

    def build_root_appender(options)
      name = "foreman"
      options[:facility] = self.class.const_get("::Syslog::Constants::#{options[:facility] || :LOG_LOCAL6}")

      case @config[:type]
      when 'stdout'
        build_console_appender(name, options)
      when 'syslog'
        build_syslog_appender(name, options)
      when 'journal', 'journald'
        build_journald_appender(name, options)
      when 'file'
        build_file_appender(name, options)
      else
        fail 'unsupported logger type, please choose stdout, file, syslog or journald'
      end
    end

    def build_console_appender(name, options = {})
      ::Logging.appenders.stdout(name, options.reverse_merge(:layout => build_layout(false)))
    end

    def add_console_appender
      return if @config[:type] == 'stdout'
      ::Logging.logger.root.add_appenders(build_console_appender("foreman"))
    end

    def build_syslog_appender(name, options)
      ::Logging.appenders.syslog(name, options.reverse_merge(:layout => build_layout(false)))
    end

    def build_journald_appender(name, options)
      ::Logging.appenders.journald(name, options.reverse_merge(:logger_name => :foreman_logger, :layout => build_layout(false)))
    end

    def build_file_appender(name, options)
      log_filename = "#{@log_directory}/#{@config[:filename]}"
      File.truncate(log_filename, 0) if @config[:truncate] && File.exist?(log_filename)
      begin
        ::Logging.appenders.file(
          name,
          options.reverse_merge(
            :filename => log_filename,
            :layout => build_layout)
        )
      rescue ArgumentError
        warn "Log file #{log_filename} cannot be opened. Falling back to STDOUT"
        nil
      end
    end

    def build_layout(enable_colors = true)
      pattern, colorize = @config[:pattern], @config[:colorize]
      pattern = @config[:sys_pattern] if @config[:type] =~ /^(journald?|syslog)$/i
      colorize = nil unless enable_colors
      case @config[:layout]
      when 'json'
        ::Logging::Layouts::Parseable.json(:items => @config[:json_items])
      when 'pattern'
        ::Logging::Layouts.pattern(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
      when 'multiline_pattern'
        pattern += "  Log trace: %F:%L method: %M\n" if @config[:log_trace]
        MultilinePatternLayout.new(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
      when 'multiline_request_pattern'
        pattern += "  Log trace: %F:%L method: %M\n" if @config[:log_trace]
        MultilineRequestPatternLayout.new(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
      end
    end

    def configure_color_scheme
      ::Logging.color_scheme(
        'bright',
        :levels => {
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red],
        },
        :date   => :green,
        :logger => :cyan,
        :line   => :yellow,
        :file   => :yellow,
        :method => :yellow
      )
    end

    # Custom pattern layout that indents multiline strings and adds | symbol to beginning of each
    # following line hence you can see what belongs to the same message
    class MultilinePatternLayout < ::Logging::Layouts::Pattern
      def format_obj(obj)
        obj.is_a?(String) ? indent_lines(obj) : super
      end

      private

      # all new lines will be indented
      def indent_lines(string)
        string.gsub("\n", "\n | ")
      end
    end

    class MultilineRequestPatternLayout < MultilinePatternLayout
      def indent_lines(string)
        string.gsub("\n", "\n #{::Logging.mdc['request'].split('-').first} | ")
      end
    end
  end

  Logging = LoggingImpl.send :new
end
