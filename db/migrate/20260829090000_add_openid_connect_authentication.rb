class AddOpenidConnectAuthentication < ActiveRecord::Migration[7.0]
  def change
    change_table :auth_sources, :bulk => true do |t|
      t.text :oidc_issuer
      t.string :oidc_client_id
      t.text :oidc_client_secret
      t.string :oidc_scopes, :null => false, :default => 'openid profile email'
      t.string :oidc_client_auth_method, :null => false, :default => 'client_secret_basic'
      t.string :oidc_allowed_algorithms, :null => false, :default => 'RS256'
      t.text :oidc_authorization_endpoint
      t.text :oidc_token_endpoint
      t.text :oidc_userinfo_endpoint
      t.text :oidc_jwks_uri
      t.text :oidc_end_session_endpoint
      t.string :oidc_login_claim, :null => false, :default => 'preferred_username'
      t.string :oidc_email_claim, :null => false, :default => 'email'
      t.string :oidc_firstname_claim, :null => false, :default => 'given_name'
      t.string :oidc_lastname_claim, :null => false, :default => 'family_name'
      t.string :oidc_groups_claim, :null => false, :default => 'groups'
      t.boolean :oidc_enabled, :null => false, :default => true
      t.boolean :oidc_use_discovery, :null => false, :default => true
      t.boolean :oidc_use_pkce, :null => false, :default => true
      t.boolean :oidc_link_verified_email, :null => false, :default => false
      t.boolean :oidc_update_user_attributes, :null => false, :default => true
      t.boolean :oidc_allow_api_bearer, :null => false, :default => false
      t.string :oidc_api_audiences
    end

    create_table :oidc_identities do |t|
      t.references :user, :null => false, :foreign_key => { :on_delete => :cascade }
      t.references :auth_source, :null => false, :foreign_key => { :on_delete => :cascade }
      t.string :subject, :null => false
      t.string :email
      t.boolean :email_verified
      t.datetime :last_login_on
      t.timestamps
    end

    add_index :oidc_identities, [:auth_source_id, :subject], :unique => true
    add_index :oidc_identities, [:user_id, :auth_source_id], :unique => true
  end
end
