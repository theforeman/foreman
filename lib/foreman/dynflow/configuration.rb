module Foreman
  module Dynflow
    class Configuration < ::Dynflow::Rails::Configuration
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
