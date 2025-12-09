class AddOidcColumnsToAuthSources < ActiveRecord::Migration[7.0]
  def change
    add_column :auth_sources, :oidc_issuer, :string
    add_column :auth_sources, :oidc_client_id, :string
    add_column :auth_sources, :oidc_client_secret, :text  # Encrypted
    add_column :auth_sources, :oidc_scopes, :string, default: 'openid email profile'

    add_column :auth_sources, :oidc_authorization_endpoint, :string
    add_column :auth_sources, :oidc_token_endpoint, :string
    add_column :auth_sources, :oidc_userinfo_endpoint, :string
    add_column :auth_sources, :oidc_jwks_uri, :string
    add_column :auth_sources, :oidc_end_session_endpoint, :string
    add_column :auth_sources, :oidc_redirect_uri, :string

    add_column :auth_sources, :oidc_auto_provision, :boolean, default: false
    add_column :auth_sources, :oidc_email_autolink, :boolean, default: false

    add_column :auth_sources, :oidc_groups_claim, :string, default: 'groups'
    add_column :auth_sources, :oidc_role_mappings, :text  # Stored as YAML/JSON

    add_index :auth_sources, :oidc_issuer
  end
end
