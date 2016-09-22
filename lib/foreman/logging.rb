require 'logging'
require 'fileutils'

::Logging::Logger.send(:include, ActiveRecord::SessionStore::Extension::LoggerSilencer)

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

      configure_color_scheme
      configure_root_logger(options)

      build_console_appender
    end

    def add_loggers(loggers = {})
      return unless loggers.is_a?(Hash)

      loggers.each do |name, config|
        add_logger(name, config)
      end
    end

    def add_logger(logger_name, logger_config)
      logger          = ::Logging.logger[logger_name]
      logger.level    = logger_config[:level] if logger_config.key?(:level)
      logger.additive = logger_config[:enabled] if logger_config.key?(:enabled)

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
      return ::Logging.logger[name] if ::Logging::Repository.instance.has_logger?(name)
      fail "Trying to use logger #{name} which has not been configured."
    end

    def logger_level(name)
      level_int = logger(name).level
      ::Logging::LEVELS.find { |n,i| i == level_int }.first
    end

    # Standard way for logging exceptions to get the most data in the log.
    # The behaviour can be influenced by this options:
    #   * :logger - the name of the logger to put the exception in ('app' by default)
    #   * :level - the logging level (:warn by default)
    def exception(context_message, exception, options = {})
      options.assert_valid_keys :level, :logger
      logger_name = options[:logger] || 'app'
      level       = options[:level] || :warn
      unless ::Logging::LEVELS.keys.include?(level.to_s)
        raise "Unexpected log level #{level}, expected one of #{::Logging::LEVELS.keys}"
      end
      self.logger(logger_name).public_send(level) do
        ([context_message, "#{exception.class}: #{exception.message}"] + exception.backtrace).join("\n")
      end
    end

    private

    def load_config(environment, overrides = {})
      fail "Logging configuration 'config/logging.yaml' not present" unless File.exist?('config/logging.yaml')
      overrides ||= {}
      overrides = overrides[environment.to_sym] if overrides.has_key?(environment.to_sym)
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

    def build_console_appender
      return unless @config[:console_inline]

      ::Logging.logger.root.add_appenders(
        ::Logging.appenders.stdout(:layout => build_layout(@config[:pattern], @config[:colorize]))
      )
    end

    # currently we support two types of appenders, rolling file and syslog
    # note that syslog ignores pattern and logs only messages
    def build_root_appender(options)
      name = "foreman"

      case @config[:type]
      when 'syslog'
        build_syslog_appender(name, options)
      when 'file'
        build_file_appender(name, options)
      else
        fail 'unsupported logger type, please choose syslog or file'
      end
    end

    def build_syslog_appender(name, options)
      ::Logging.appenders.syslog(name, options.reverse_merge(:facility => ::Syslog::Constants::LOG_DAEMON))
    end

    def build_file_appender(name, options)
      log_filename = "#{@log_directory}/#{@config[:filename]}"
      File.truncate(log_filename, 0) if @config[:truncate] && File.exist?(log_filename)
      begin
        ::Logging.appenders.file(
          name,
          options.reverse_merge(:filename => log_filename,
                                :layout   => build_layout(@config[:pattern], @config[:colorize]))
        )
      rescue ArgumentError
        warn "Log file #{log_filename} cannot be opened. Falling back to STDOUT"
        nil
      end
    end

    def build_layout(pattern, colorize)
      pattern += "  Log trace: %F:%L method: %M\n" if @config[:log_trace]
      MultilinePatternLayout.new(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
    end

    def configure_color_scheme
      ::Logging.color_scheme(
        'bright',
        :levels => {
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red]
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
  end

  Logging = LoggingImpl.send :new
end
