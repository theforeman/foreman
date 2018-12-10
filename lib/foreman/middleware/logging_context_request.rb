module Foreman
  module Middleware
    class LoggingContextRequest
      def initialize(app)
        @app = app
      end

      def call(env)
        ::Logging.mdc['remote_ip'] = env['action_dispatch.remote_ip'].try(:to_s)
        ::Logging.mdc['request'] = env['action_dispatch.request_id']
        @app.call(env)
      ensure
        # remove all variables set by middleware and app
        ::Logging.mdc.clear
      end
    end
  end
end
