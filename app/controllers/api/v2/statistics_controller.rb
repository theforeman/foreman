module Api
  module V2
    # This controller just informs about the plugin
    class StatisticsController < V2::BaseController
      prepend_before_action :fail_and_inform_about_plugin

      resource_description do
        desc 'This resource has been deprecated, to continue using it please install Foreman Statistics plugin and use its API endpoints.'
        deprecated true
      end

      api :GET, "/statistics/", N_("Get statistics")
      description 'This resource has been deprecated, to continue using it, install the Foreman Statistics plugin.'
      def index
      end

      def fail_and_inform_about_plugin
        render json: { message: _('To access /statistics API you need to install Foreman Statistics plugin') }, status: :not_implemented
      end
    end
  end
end
