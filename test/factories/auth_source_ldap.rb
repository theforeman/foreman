FactoryBot.define do
  factory :auth_source_ldap do
    sequence(:name) { |n| "auth_source_ldap_#{n}" }
    sequence(:host) { |n| "host_#{n}" }
    attr_mail { "some@where.com" }
    attr_login { 'value' }
    attr_firstname { 'ohad' }
    attr_lastname { 'daho' }
    port { '389' }
    server_type { 'posix' }
  end

  trait :posix

  trait :free_ipa do
    server_type { 'free_ipa' }
  end

  trait :active_directory do
    server_type { 'active_directory' }
  end

  trait :service_account do
    account { 'foremanservice' }
    account_password { 'f0rem4n' }
  end

  factory :free_ipa_auth_source,         :traits => [:free_ipa]
  factory :active_directory_auth_source, :traits => [:active_directory]
  factory :posix_auth_source,            :traits => [:posix]
end
