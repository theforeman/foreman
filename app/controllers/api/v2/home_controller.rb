module Api
  module V2
    class HomeController < V2::BaseController
      include Foreman::Controller::SmartProxyAuth

      before_action :require_admin, :only => [:index]
      layout false

      api :GET, "/", N_("Show available API links")

      def index
        # we need to load apipie documentation to show all the links.
        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
      end

      add_smart_proxy_filters :status
      api :GET, "/status/", N_("Show status")

      def status
        @remote_ip = request.remote_ip if detected_proxy
      end
    end
  end
end
