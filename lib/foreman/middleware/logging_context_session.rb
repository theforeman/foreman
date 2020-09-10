require 'securerandom'

module Foreman
  module Middleware
    class LoggingContextSession
      def initialize(app)
        @app = app
      end

      def call(env)
        session = env['rack.session']

        if env["rack.session"].id.present?
          # use random token to prevent hijack.
          session['logging_token'] ||= SecureRandom.uuid
          ::Logging.mdc['session'] = session['logging_token']
        else
          # or store request token instead of session
          ::Logging.mdc['session'] = env['action_dispatch.request_id']
        end

        @app.call(env)
      end
    end
  end
end
