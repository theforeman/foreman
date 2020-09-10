module Api
  module V2
    class AuthSourceExternalsController < V2::BaseController
      include Foreman::Controller::Parameters::AuthSourceExternal

      before_action :find_resource, :only => %w{show update}

      api :GET, "/auth_source_externals/", N_("List external authentication sources")
      api :GET, '/locations/:location_id/auth_source_externals/',
        N_('List external authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source_externals/',
        N_('List external authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(AuthSourceExternal)

      def index
        @auth_source_externals = resource_scope_for_index
      end

      api :GET, "/auth_source_externals/:id/", N_("Show an external authentication source")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :auth_source_external do
        param :auth_source_external, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :PUT, "/auth_source_externals/:id/", N_("Update an external authentication source")
      param :id, :identifier, :required => true
      param_group :auth_source_external

      def update
        process_response @auth_source_external.update(auth_source_external_params)
      end

      private

      def controller_permission
        'authenticators'
      end
    end
  end
end
