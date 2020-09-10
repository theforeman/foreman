module Foreman
  class Plugin
    # Configures logging for plugins and creates loggers per defined logger as well as
    # creates a default logger based on the name of the plugin. Note that even though
    # these loggers are created, the plugin must still use them directly within the code
    # base.
    #
    # For a plugin named 'foreman_docker', a default logger will be created that can be
    # accessed via:
    #
    #   Foreman::Logging.logger['foreman_docker']
    #
    # A plugin can specify other custom loggers and specify them using the same syntax as
    # the Foreman default loggers. For example, the foreman_docker plugin could specify
    # a REST logger for Docker commands:
    #
    #   {:loggers => :rest => {:enabled => true}}
    #
    # This will in turn create both the default logger and a logger named 'foreman_docker/rest'
    # which will output the same way in the logs. Note that all plugin loggers are name spaced
    # based upon the ID of the plugin specified in the plugin definition. This is to prevent
    # potential name clashes when viewing the logs. In other words, instead of just seeing:
    #
    # 2015-05-13 13:28:22 [rest] [D] Debugging message for Docker REST call /docker
    # 2015-05-13 13:28:22 [rest] [D] Pulp REST call made to /pulp/api
    #
    # The logs will show:
    #
    # 2015-05-13 13:28:22 [foreman_docker/rest] [D] Debugging message for Docker REST call /docker
    # 2015-05-13 13:28:22 [katello/rest] [D] Pulp REST call made to /pulp/api
    #
    class Logging
      attr_reader :config, :plugin_id

      def initialize(plugin_id)
        @plugin_id = plugin_id
        @config = {:loggers => {}}
      end

      def configure(config)
        warn "Foreman::Logging is undefined and no plugin loggers have been defined" unless defined?(Foreman::Logging)
        @config = config if config

        loggers.each do |name, logger_config|
          add_logger(name, logger_config)
        end
      end

      def add_logger(name, logger_config)
        @config[:loggers] = {name.to_s => logger_config}
        Foreman::Logging.add_logger(namespace(name), logger_config)
      end

      def loggers
        config = @config[:loggers] || {}
        config[@plugin_id] = {:enabled => true} unless config.key?(@plugin_id)
        config
      end

      def namespace(name)
        return name.to_s if @plugin_id.to_s == name.to_s
        "#{@plugin_id}/#{name}"
      end
    end
  end
end
