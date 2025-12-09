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
          :oidc_authorization_endpoint,
          :oidc_token_endpoint,
          :oidc_userinfo_endpoint,
          :oidc_jwks_uri,
          :oidc_end_session_endpoint,
          :oidc_auto_provision,
          :oidc_email_autolink,
          :oidc_groups_claim,
          :oidc_role_mappings,
          :onthefly_register

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def auth_source_oidc_params
    self.class.auth_source_oidc_params_filter.filter_params(params, parameter_filter_context)
  end
end
