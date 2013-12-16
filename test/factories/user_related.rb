FactoryGirl.define do
  factory :usergroup do
    sequence(:name) {|n| "usergroup#{n}" }
  end

  factory :user do
    auth_source { AuthSourceInternal.first }
    password 'password'
    sequence(:login) {|n| "user#{n}" }

    trait :with_mail do
      sequence(:mail) {|n| "email#{n}@example.com" }
    end
  end

  factory :permission do
    sequence(:name) {|n| "view_#{n}" }
    resource_type nil

    trait :host do
      resource_type 'Host'
    end

    trait :domain do
      resource_type 'Domain'
    end
  end

  factory :role do
    sequence(:name) {|n| "role #{n}" }
    builtin 1
    permissions [
                    FactoryGirl.create(:permission),
                    FactoryGirl.create(:permission),
                ]
  end

  factory :user_role do
    role { FactoryGirl.create :role }

    factory :user_user_role do
      owner { FactoryGirl.create :user }
    end

    factory :user_group_user_role do
      owner { FactoryGirl.create :usergroup }
    end
  end

  factory :usergroup_member do
    usergroup { FactoryGirl.create :usergroup }

    factory :user_usergroup_member do
      member { FactoryGirl.create :user }
    end

    factory :usergroup_usergroup_member do
      member { FactoryGirl.create :usergroup }
    end
  end

  factory :filter do
    search nil

    trait :on_name_all do
      search 'name ~ *'
    end

    trait :on_name_starting_with_a do
      search 'name ~ a*'
    end

    trait :on_name_starting_with_b do
      search 'name ~ b*'
    end
  end

end
