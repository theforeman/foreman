module Api
  module V2
    class PingController < BaseController
      skip_before_action :authorize, only: [:ping]

      api :GET, '/ping', N_("Shows status of Foreman system and it's subcomponents")
      description N_('This service is available for unauthenticated users')
      def ping
        @results = Ping.ping
      end

      api :GET, '/statuses', N_("Shows status and version information of Foreman system and it's subcomponents")
      description N_('This service is only available for authenticated users')
      def statuses
        @results = Ping.statuses
      end
    end
  end
end
