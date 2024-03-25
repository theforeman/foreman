FactoryBot.define do
  factory :render_status do
    host
    provisioning_template
    safemode { true }
    success { true }

    trait :with_hostgroup do
      hostgroup
      host { nil }
    end

    trait :safemode do
      safemode { true }
    end

    trait :unsafemode do
      safemode { false }
    end

    trait :success do
      success { true }
    end

    trait :failure do
      success { false }
    end
  end
end
