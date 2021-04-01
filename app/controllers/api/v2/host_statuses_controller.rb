module Api
  module V2
    class HostStatusesController < V2::BaseController
      include Api::Version2

      api :GET, "/host_statuses", N_("List of host statuses")
      param_group :pagination, ::Api::V2::BaseController

      def index
        @host_statuses = resource_scope_for_index
      end

      private

      def resource_scope(*args, &block)
        HostStatusPresenter.all
      end

      def controller_permission
        'hosts'
      end
    end
  end
end
