module Api
  module V2
    class AuthSourceOidcsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::AuthSourceOidc

      before_action :find_resource, only: [:show, :update, :destroy, :test_connection, :status]

      api :GET, "/auth_source_oidcs/", N_("List all OIDC authentication sources")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(AuthSourceOidc)
      def index
        @auth_source_oidcs = resource_scope_for_index
      end

      api :GET, "/auth_source_oidcs/:id/", N_("Show an OIDC authentication source")
      param :id, :identifier, required: true
      def show
      end

      def_param_group :auth_source_oidc do
        param :auth_source_oidc, Hash, required: true, action_aware: true do
          param :name, String, required: true, desc: N_("Name of the authentication source")
          param :oidc_issuer, String, required: true, desc: N_("OIDC Issuer URL (e.g., https://accounts.google.com)")
          param :oidc_client_id, String, required: true, desc: N_("OIDC Client ID")
          param :oidc_client_secret, String, required: true, desc: N_("OIDC Client Secret")
          param :oidc_scopes, String, desc: N_("OIDC scopes (space-separated, default: 'openid email profile')")
          param :oidc_authorization_endpoint, String, desc: N_("Authorization endpoint URL (only for IdPs without discovery support)")
          param :oidc_token_endpoint, String, desc: N_("Token endpoint URL (only for IdPs without discovery support)")
          param :oidc_userinfo_endpoint, String, desc: N_("UserInfo endpoint URL (only for IdPs without discovery support)")
          param :oidc_jwks_uri, String, desc: N_("JWKS URI (only for IdPs without discovery support)")
          param :oidc_end_session_endpoint, String, desc: N_("End session endpoint for logout (optional)")
          param :oidc_auto_provision, :bool, desc: N_("Automatically create users on first login")
          param :oidc_email_autolink, :bool, desc: N_("Automatically link existing users by email")
          param :oidc_groups_claim, String, desc: N_("Name of the claim containing user groups")
          param :oidc_role_mappings, String, desc: N_("YAML mapping of OIDC groups to Foreman roles")
          param :onthefly_register, :bool, desc: N_("Enable on-the-fly user creation")
          param :location_ids, Array, desc: N_("Replace locations with given ids")
          param :organization_ids, Array, desc: N_("Replace organizations with given ids")
        end
      end

      api :POST, "/auth_source_oidcs/", N_("Create an OIDC authentication source")
      param_group :auth_source_oidc, as: :create
      def create
        @auth_source_oidc = AuthSourceOidc.new(auth_source_oidc_params)
        process_response @auth_source_oidc.save
      end

      api :PUT, "/auth_source_oidcs/:id/", N_("Update an OIDC authentication source")
      param :id, :identifier, required: true
      param_group :auth_source_oidc
      def update
        process_response @auth_source_oidc.update(auth_source_oidc_params)
      end

      api :DELETE, "/auth_source_oidcs/:id/", N_("Delete an OIDC authentication source")
      param :id, :identifier, required: true
      def destroy
        process_response @auth_source_oidc.destroy
      end

      api :GET, "/auth_source_oidcs/:id/status", N_("Check OIDC configuration status for an authentication source")
      param :id, :identifier, required: true
      def status
        has_manual_endpoints = [
          @auth_source_oidc.oidc_authorization_endpoint,
          @auth_source_oidc.oidc_token_endpoint,
          @auth_source_oidc.oidc_jwks_uri,
        ].all?(&:present?)

        render json: {
          id: @auth_source_oidc.id,
          name: @auth_source_oidc.name,
          issuer: @auth_source_oidc.oidc_issuer,
          redirect_uri: @auth_source_oidc.oidc_redirect_uri,
          using_discovery: !has_manual_endpoints,
          client_id: @auth_source_oidc.oidc_client_id.present? ? "[configured]" : nil,
          client_secret: @auth_source_oidc.oidc_client_secret.present? ? "[configured]" : nil,
          endpoints: {
            authorization: @auth_source_oidc.oidc_authorization_endpoint,
            token: @auth_source_oidc.oidc_token_endpoint,
            userinfo: @auth_source_oidc.oidc_userinfo_endpoint,
            jwks: @auth_source_oidc.oidc_jwks_uri,
            end_session: @auth_source_oidc.oidc_end_session_endpoint,
          },
          options: {
            auto_provision: @auth_source_oidc.oidc_auto_provision,
            email_autolink: @auth_source_oidc.oidc_email_autolink,
            groups_claim: @auth_source_oidc.oidc_groups_claim,
            scopes: @auth_source_oidc.oidc_scopes,
          },
          message: has_manual_endpoints ? _("Using manually configured endpoints") : _("Using OIDC discovery"),
        }, status: :ok
      end

      api :GET, "/auth_source_oidcs/:id/test_connection", N_("Test OIDC connection by fetching discovery document")
      param :id, :identifier, required: true
      def test_connection
        config = fetch_discovery_document(@auth_source_oidc.oidc_issuer)
        render json: {
          success: true,
          message: _("Connection to OIDC provider successful - discovery is supported"),
          provider_info: {
            issuer: config['issuer'],
            scopes_supported: config['scopes_supported'],
            response_types_supported: config['response_types_supported'],
            grant_types_supported: config['grant_types_supported'],
          },
        }
      rescue OidcDiscoveryError => e
        render json: {
          success: false,
          message: _("Discovery not available: %s. Manual endpoint configuration required.") % e.message,
        }, status: :unprocessable_entity
      end

      private

      class OidcDiscoveryError < StandardError; end

      def resource_class
        AuthSourceOidc
      end

      def action_permission
        case params[:action]
        when 'test_connection', 'status'
          :view
        else
          super
        end
      end

      def controller_permission
        'authenticators'
      end

      def fetch_discovery_document(issuer_url)
        raise OidcDiscoveryError, _("Issuer URL is blank") if issuer_url.blank?

        discovery_url = "#{issuer_url.chomp('/')}/.well-known/openid-configuration"
        uri = URI.parse(discovery_url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.open_timeout = 10
        http.read_timeout = 10

        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        unless response.is_a?(Net::HTTPSuccess)
          raise OidcDiscoveryError, _("HTTP %{code} %{message}") % { code: response.code, message: response.message }
        end

        JSON.parse(response.body)
      rescue URI::InvalidURIError => e
        raise OidcDiscoveryError, _("Invalid issuer URL: %{error}") % { error: e.message }
      rescue JSON::ParserError => e
        raise OidcDiscoveryError, _("Invalid JSON response: %{error}") % { error: e.message }
      rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
        raise OidcDiscoveryError, _("Connection failed: %{error}") % { error: e.message }
      rescue OpenSSL::SSL::SSLError => e
        raise OidcDiscoveryError, _("SSL error: %{error}") % { error: e.message }
      end
    end
  end
end
