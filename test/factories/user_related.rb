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

  factory :role do
    sequence(:name) {|n| "role #{n}" }
    builtin 1
    permissions [:view_architectures, :view_audit_logs]
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

end
