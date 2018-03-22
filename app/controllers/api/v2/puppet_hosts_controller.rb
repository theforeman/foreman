module Api
  module V2
    class PuppetHostsController < V2::BaseController
      include Api::Version2
      include HostsControllerExtension

      check_permissions_for ['puppetrun']

      api :PUT, "/hosts/:id/puppetrun", N_("Force a Puppet agent run on the host")
      param :id, :identifier_dottable, :required => true

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
      end

      def action_permission
        case params[:action]
          when 'puppetrun'
            :puppetrun
          else
            super
        end
      end
    end
  end
end
