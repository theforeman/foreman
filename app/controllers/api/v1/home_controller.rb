module Api
  module V1
    class HomeController < V1::BaseController
      before_filter :require_admin, :only => [:index]

      api :GET, "/", "Show available links."

      def index
        # we need to load apipie documentation to show all the links.
        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
      end

      api :GET, "/status/", "Show status."

      def status
      end
    end
  end
end

