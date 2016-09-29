module Api
  module V2
    class HomeController < V2::BaseController
      before_action :require_admin, :only => [:index]
      layout false

      api :GET, "/", N_("Show available API links")

      def index
        # we need to load apipie documentation to show all the links.
        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
      end

      api :GET, "/status/", N_("Show status")

      def status
      end
    end
  end
end
