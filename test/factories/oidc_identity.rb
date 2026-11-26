FactoryBot.define do
  factory :oidc_identity do
    user
    association :auth_source, :factory => :auth_source_oidc
    sequence(:subject) { |number| "subject-#{number}" }
    sequence(:email) { |number| "oidc-#{number}@example.test" }
    email_verified { true }
  end
end
