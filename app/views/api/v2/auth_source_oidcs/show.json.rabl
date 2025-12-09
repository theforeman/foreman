object @auth_source_oidc

extends "api/v2/auth_source_oidcs/main"

attributes :oidc_authorization_endpoint, :oidc_token_endpoint, :oidc_userinfo_endpoint,
  :oidc_jwks_uri, :oidc_end_session_endpoint, :oidc_auto_provision,
  :oidc_email_autolink, :oidc_groups_claim, :oidc_role_mappings,
  :onthefly_register, :created_at, :updated_at

node(:login_url) { |auth_source| auth_source.login_url }
node(:redirect_uri) { |auth_source| auth_source.redirect_uri }

child :locations do
  extends "api/v2/taxonomies/base"
end

child :organizations do
  extends "api/v2/taxonomies/base"
end
