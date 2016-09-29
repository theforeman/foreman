module Middleware
  class TaggedLogging
    def initialize(app)
      @app = app
    end

    def call(env)
      ::Logging.mdc['request'] = env['action_dispatch.request_id']

      request = ActionDispatch::Request.new(env)
      session_id = request.cookie_jar['_session_id']
      ::Logging.mdc['session'] = if session_id.present?
                                   session_id.gsub(/[^\w\-]/, '').first(32)
                                 else
                                   env['action_dispatch.request_id']
                                 end

      @app.call(env)
    ensure
      ::Logging.mdc.delete('request')
      ::Logging.mdc.delete('session')
    end
  end
end
