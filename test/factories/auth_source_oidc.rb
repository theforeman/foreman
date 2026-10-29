FactoryBot.define do
  factory :auth_source_oidc do
    sequence(:name) { |number| "oidc_#{number}" }
    sequence(:oidc_issuer) { |number| "https://idp#{number}.example.test/realms/foreman" }
    sequence(:oidc_client_id) { |number| "foreman-#{number}" }
    oidc_client_secret { 'secret' }
    oidc_scopes { 'openid profile email' }
    oidc_client_auth_method { 'client_secret_basic' }
    oidc_allowed_algorithms { 'RS256' }
    oidc_enabled { true }
    oidc_use_discovery { true }
    oidc_use_pkce { true }
  end
end
