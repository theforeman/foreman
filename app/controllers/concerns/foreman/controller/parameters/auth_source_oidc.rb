module Foreman::Controller::Parameters::AuthSourceOidc
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def auth_source_oidc_params_filter
      Foreman::ParameterFilter.new(::AuthSourceOidc).tap do |filter|
        filter.permit :name,
          :oidc_issuer,
          :oidc_client_id,
          :oidc_client_secret,
          :oidc_scopes,
          :oidc_client_auth_method,
          :oidc_allowed_algorithms,
          :oidc_authorization_endpoint,
          :oidc_token_endpoint,
          :oidc_userinfo_endpoint,
          :oidc_jwks_uri,
          :oidc_end_session_endpoint,
          :oidc_login_claim,
          :oidc_email_claim,
          :oidc_firstname_claim,
          :oidc_lastname_claim,
          :oidc_groups_claim,
          :oidc_enabled,
          :oidc_use_discovery,
          :oidc_use_pkce,
          :oidc_link_verified_email,
          :oidc_update_user_attributes,
          :oidc_allow_api_bearer,
          :oidc_api_audiences,
          :onthefly_register,
          :usergroup_sync,
          :cacert

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def auth_source_oidc_params
    self.class.auth_source_oidc_params_filter.filter_params(params, parameter_filter_context)
  end
end
