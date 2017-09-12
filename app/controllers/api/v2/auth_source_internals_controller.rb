module Api
  module V2
    class AuthSourceInternalsController < V2::BaseController
      before_action :find_resource, :only => %w{show}

      api :GET, "/auth_source_internals/", N_("List internal authentication sources")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @auth_source_internals = resource_scope_for_index
      end

      api :GET, "/auth_source_internals/:id/", N_("Show an internal authentication sources")
      param :id, :identifier, :required => true

      def show
      end
    end
  end
end
