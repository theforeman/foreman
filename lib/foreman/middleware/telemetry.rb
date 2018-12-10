module Foreman
  module Middleware
    class Telemetry
      def initialize(app)
        @app = app
      end

      def call(env)
        Thread.current[:foreman_telemetry_gcstats] = GC.stat if Foreman::Telemetry.instance.enabled?
        @app.call(env)
      end
    end
  end
end
