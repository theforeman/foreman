class AddOidcFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :oidc_subject, :string
    add_column :users, :oidc_issuer, :string
    add_column :users, :oidc_email, :string
    add_column :users, :oidc_provider, :string, default: 'openid_connect'

    add_index :users, [:oidc_subject, :oidc_issuer], unique: true, name: 'index_users_on_oidc_subject_and_issuer'
  end
end
