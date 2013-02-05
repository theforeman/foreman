module Api
  module V1
    class HomeController < V1::BaseController

      api :GET, "/", "Show available links."

      def index
      end

      api :GET, "/status/", "Show status."

      def status
      end

      def route_error
        render_error 'route_error', :status => :not_found
      end

    end
  end
end

