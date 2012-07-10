module Api
  module V1
    class HomeController < V1::BaseController

      def index
      end

      def status
      end

      def route_error
        render_error 'route_error', :status => :not_found
      end

    end
  end
end

