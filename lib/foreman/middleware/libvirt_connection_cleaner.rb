module Foreman
  module Middleware
    class LibvirtConnectionCleaner
      def initialize(app)
        @app = app
      end

      def call(env)
        result = @app.call(env)

        # Libvirt compute resource does rely on TCP+SSH tunnel which needs to be
        # properly closed at the end of each request to prevent connection leaks.
        Foreman::Model::Libvirt.terminate_connection

        result
      end
    end
  end
end
