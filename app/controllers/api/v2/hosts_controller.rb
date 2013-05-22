module Api
  module V2
    class HostsController < V1::HostsController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy status puppetrun}

      api :GET, "/hosts/:id/puppetrun", "Force a puppet run on the agent."

      def puppetrun
        process_response @host.puppetrun!
      end

    end
  end
end
