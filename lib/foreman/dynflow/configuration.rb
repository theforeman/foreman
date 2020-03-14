module Foreman
  module Dynflow
    class Configuration < ::Dynflow::Rails::Configuration
      def initialize
        super
        self.pool_size = SETTINGS.fetch(:dynflow, {})
                                 .fetch(:pool_size, pool_size)
        self.lazy_initialization = rake_task_with_executor? || lazy_initialization
      end

      # Action related info such as exceptions raised inside the actions' methods
      def action_logger
        Foreman::Logging.logger('background')
      end

      # Dynflow related info about the progress of the execution
      def dynflow_logger
        Foreman::Logging.logger('dynflow')
      end
    end
  end
end
