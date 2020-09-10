FactoryBot.define do
  factory :usergroup do
    sequence(:name) { |n| "usergroup#{n}" }
  end

  factory :external_usergroup do
    sequence(:name) { |n| "external_usergroup#{n}" }
    usergroup { FactoryBot.create :usergroup }
    auth_source { FactoryBot.create :auth_source_ldap }
  end

  factory :user do
    auth_source { AuthSourceInternal.first }
    password { 'password' }
    sequence(:login) { |n| "user#{n}" }
    organizations { [Organization.find_or_initialize_by(name: 'Organization 1')] }
    locations { [Location.find_or_initialize_by(name: 'Location 1')] }

    trait :admin do
      admin { true }
    end

    trait :with_mail do
      sequence(:mail) { |n| "email#{n}@example.com" }
    end

    trait :with_utf8_mail do
      mail { "Pelé@example.com" }
    end

    trait :with_mail_notification do
      sequence(:mail) { |n| "email#{n}@example.com" }
      mail_notifications { [FactoryBot.create(:mail_notification)] }
    end

    trait :with_widget do
      after(:create) { |user, evaluator| FactoryBot.create(:widget, :user => user) }
    end

    trait :with_usergroup do
      usergroups { [FactoryBot.create(:usergroup)] }
    end

    trait :with_ssh_key do
      after(:create) { |user, _| FactoryBot.create(:ssh_key, user: user) }
    end
  end

  factory :permission do
    sequence(:name) { |n| "view_#{n}" }
    resource_type { nil }

    trait :host do
      resource_type { 'Host' }
    end

    trait :domain do
      resource_type { 'Domain' }
    end

    trait :architecture do
      resource_type { 'Architecture' }
    end

    trait :report do
      resource_type { 'ConfigReport' }
    end
  end

  factory :role do
    sequence(:name) { |n| "role #{n}" }
    locations { [] }
    organizations { [] }
    builtin { 0 }
  end

  factory :user_role do
    role { FactoryBot.create :role }

    factory :user_user_role do
      owner { FactoryBot.create :user }
    end

    factory :user_group_user_role do
      owner { FactoryBot.create :usergroup }
    end
  end

  factory :usergroup_member do
    usergroup { FactoryBot.create :usergroup }

    factory :user_usergroup_member do
      member { FactoryBot.create :user }
    end

    factory :usergroup_usergroup_member do
      member { FactoryBot.create :usergroup }
    end
  end

  factory :filter do
    search { nil }
    role { FactoryBot.create :role }
    permissions { [FactoryBot.create(:permission, :host)] }

    trait :on_name_all do
      search { 'name ~ *' }
    end

    trait :on_name_starting_with_a do
      search { 'name ~ a*' }
    end

    trait :on_name_starting_with_b do
      search { 'name ~ b*' }
    end
  end

  factory :widget do
    sequence(:name) { |n| "Status Table #{n}" }
    template { 'status_widget' }
  end

  factory :jwt_secret do
    token { SecureRandom.base64 }
  end
end
