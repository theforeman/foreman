module Api
  module V2
    class HostsController < V1::HostsController
      include Api::Version2

      before_filter :find_resource, :only => :puppetrun

      api :GET, "/hosts/:id/puppetrun", "Force a puppet run on the agent."

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
      end

    end
  end
end
