module Api
  module V2
    class PuppetHostsController < V2::BaseController
      include Api::Version2
      include HostsControllerExtension

      prepend_before_action :fail_and_inform_about_plugin

      resource_description do
        desc 'This resource has been deprecated, to continue using it please install Foreman Remote Execution Plugin.'
        deprecated true
      end

      api :PUT, "/hosts/:id/puppetrun", N_("Force a Puppet agent run on the host")
      description 'This resource has been deprecated, to continue using it, install Foreman Remote Execution Plugin.'
      param :id, :identifier_dottable, :required => true

      def puppetrun
      end

      def fail_and_inform_about_plugin
        render json: { message: _('To access Puppetrun feature you need to install Foreman Remote Execution Plugin') }, status: :not_implemented
      end
    end
  end
end
