module Api
  module V2
    class AuthSourceOidcsController < V2::BaseController
      include Foreman::Controller::Parameters::AuthSourceOidc

      wrap_parameters AuthSourceOidc,
        :include => auth_source_oidc_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_resource, :only => %w[show update destroy test]

      api :GET, '/auth_source_oidcs/', N_('List all OpenID Connect authentication sources')
      api :GET, '/locations/:location_id/auth_source_oidcs/', N_('List OpenID Connect authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source_oidcs/', N_('List OpenID Connect authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(AuthSourceOidc)

      def index
        @auth_source_oidcs = resource_scope_for_index
      end

      api :GET, '/auth_source_oidcs/:id/', N_('Show an OpenID Connect authentication source')
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :auth_source_oidc do
        param :auth_source_oidc, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :oidc_issuer, String, :required => true
          param :oidc_client_id, String, :required => true
          param :oidc_client_secret, String
          param :oidc_scopes, String
          param :oidc_client_auth_method, AuthSourceOidc::CLIENT_AUTH_METHODS.keys
          param :oidc_allowed_algorithms, String
          param :oidc_authorization_endpoint, String
          param :oidc_token_endpoint, String
          param :oidc_userinfo_endpoint, String
          param :oidc_jwks_uri, String
          param :oidc_end_session_endpoint, String
          param :oidc_login_claim, String
          param :oidc_email_claim, String
          param :oidc_firstname_claim, String
          param :oidc_lastname_claim, String
          param :oidc_groups_claim, String
          param :oidc_enabled, :bool
          param :oidc_use_discovery, :bool
          param :oidc_use_pkce, :bool
          param :oidc_link_verified_email, :bool
          param :oidc_update_user_attributes, :bool
          param :oidc_allow_api_bearer, :bool
          param :oidc_api_audiences, String, :desc => N_('Dedicated access-token audiences, different from the browser client ID')
          param :onthefly_register, :bool
          param :usergroup_sync, :bool
          param :cacert, String
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/auth_source_oidcs/', N_('Create an OpenID Connect authentication source')
      param_group :auth_source_oidc, :as => :create

      def create
        @auth_source_oidc = AuthSourceOidc.new(auth_source_oidc_params)
        process_response @auth_source_oidc.save
      end

      api :PUT, '/auth_source_oidcs/:id/', N_('Update an OpenID Connect authentication source')
      param :id, String, :required => true
      param_group :auth_source_oidc

      def update
        process_response @auth_source_oidc.update(auth_source_oidc_params)
      end

      api :PUT, '/auth_source_oidcs/:id/test/', N_('Test an OpenID Connect authentication source')
      param :id, String, :required => true

      def test
        result = @auth_source_oidc.test_connection
        render :test, :locals => { :success => true, :message => result[:message] }
      rescue Foreman::Exception => exception
        render :test, :locals => { :success => false, :message => exception.message }
      end

      api :DELETE, '/auth_source_oidcs/:id/', N_('Delete an OpenID Connect authentication source')
      param :id, String, :required => true

      def destroy
        process_response @auth_source_oidc.destroy
      end

      private

      def action_permission
        params[:action] == 'test' ? 'edit' : super
      end

      def controller_permission
        'authenticators'
      end

      def resource_scope(...)
        super.merge(AuthSourceOidc.with_taxonomy_scope)
      end
    end
  end
end
