require 'securerandom'

module Middleware
  class SessionSafeLogging
    def initialize(app)
      @app = app
    end

    def call(env)
      session = env['rack.session']

      # Store a UUID in the session to be used as an alternative to the session
      # ID itself in logs, which might be hijacked.
      session['session_safe'] ||= SecureRandom.hex(32)
      ::Logging.mdc['session_safe'] = session['session_safe']

      @app.call(env)
    ensure
      ::Logging.mdc.delete('session_safe')
    end
  end
end
