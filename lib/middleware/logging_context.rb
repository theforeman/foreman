require 'securerandom'

module Middleware
  class LoggingContext
    def initialize(app)
      @app = app
    end

    def call(env)
      session = env['rack.session']
      ::Logging.mdc['remote_ip'] = env['action_dispatch.remote_ip'].try(:to_s)
      ::Logging.mdc['request'] = env['action_dispatch.request_id']

      if env["rack.session"].id.present?
        # use random token to prevent hijack.
        session['logging_token'] ||= SecureRandom.uuid
        ::Logging.mdc['session'] = session['logging_token']
      else
        # or store request token instead of session
        ::Logging.mdc['session'] = env['action_dispatch.request_id']
      end

      @app.call(env)
    ensure
      # remove all variables set by middleware and app
      ::Logging.mdc.clear
    end
  end
end
