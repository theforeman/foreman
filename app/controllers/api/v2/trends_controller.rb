module Api
  module V2
    # This controller just informs about the plugin
    class TrendsController < V2::BaseController
      prepend_before_action :fail_and_inform_about_plugin

      resource_description do
        desc 'This resource has been deprecated, to continue using it please install Foreman Statistics plugin and use its API enpoints.'
        deprecated true
      end

      api :GET, "/trends/", N_("List of trends counters")
      description 'This resource has been deprecated, to continue using it, install Foreman Statistics plugin.'
      def index
      end

      api :GET, "/trends/:id/", N_("Show a trend")
      description 'This resource has been deprecated, to continue using it, install Foreman Statistics plugin.'
      def show
      end

      api :POST, "/trends/", N_("Create a trend counter")
      description 'This resource has been deprecated, to continue using it, install Foreman Statistics plugin.'
      def create
      end

      api :DELETE, "/trends/:id/", N_("Delete a trend counter")
      description 'This resource has been deprecated, to continue using it, install Foreman Statistics plugin.'
      def destroy
      end

      def fail_and_inform_about_plugin
        render json: { message: _('To access /trends API you need to install Foreman Statistics plugin') }, status: :not_implemented
      end
    end
  end
end
