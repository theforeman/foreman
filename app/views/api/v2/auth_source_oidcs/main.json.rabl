object @auth_source_oidc

extends 'api/v2/auth_source_oidcs/base'

attributes :oidc_issuer, :oidc_client_id, :oidc_scopes, :oidc_client_auth_method,
  :oidc_allowed_algorithms, :oidc_authorization_endpoint, :oidc_token_endpoint,
  :oidc_userinfo_endpoint, :oidc_jwks_uri, :oidc_end_session_endpoint,
  :oidc_login_claim, :oidc_email_claim, :oidc_firstname_claim, :oidc_lastname_claim,
  :oidc_groups_claim, :oidc_enabled, :oidc_use_discovery, :oidc_use_pkce,
  :oidc_link_verified_email, :oidc_update_user_attributes, :onthefly_register,
  :oidc_allow_api_bearer, :oidc_api_audiences, :usergroup_sync, :cacert,
  :created_at, :updated_at
