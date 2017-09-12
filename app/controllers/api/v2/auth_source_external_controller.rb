module Api
  module V2
    class AuthSourceExternalController < V2::BaseController
      include Api::TaxonomyScope
      before_action :find_resource, :only => %w{show}

      api :GET, "/auth_source_external/", N_("List external authentication sources")
      api :GET, '/locations/:location_id/auth_source_external/',
          N_('List external authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source_external/',
          N_('List external authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @auth_source_external = resource_scope_for_index
      end

      api :GET, "/auth_source_external/:id/", N_("Show an external authentication source")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :auth_source_external do
        param :auth_source_external, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :PUT, "/auth_source_external/:id/", N_("Update an external authentication source")
      param :id, String, :required => true
      param_group :auth_source_external

      def update
        process_response @auth_source_external.update_attributes(auth_source_external_params)
      end

      private

      def convert_type
        params[:interface][:type] = InterfaceTypeMapper.map(params[:interface][:type])
      rescue InterfaceTypeMapper::UnknownTypeExeption => e
        render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => e.to_s }
      end

      def controller_permission
        'authenticators'
      end
    end
  end
end
