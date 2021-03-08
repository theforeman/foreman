FactoryBot.define do
  factory :rendering_status_combination, class: HostStatus::RenderingStatusCombination do
    host
    association :template, factory: :provisioning_template

    trait :safemode_ok do
      safemode_status { HostStatus::RenderingStatusCombination::OK }
    end

    trait :unsafemode_ok do
      unsafemode_status { HostStatus::RenderingStatusCombination::OK }
    end

    trait :safemode_warn do
      safemode_status { HostStatus::RenderingStatusCombination::WARN }
    end

    trait :unsafemode_warn do
      unsafemode_status { HostStatus::RenderingStatusCombination::WARN }
    end

    trait :safemode_error do
      safemode_status { HostStatus::RenderingStatusCombination::ERROR }
    end

    trait :unsafemode_error do
      unsafemode_status { HostStatus::RenderingStatusCombination::ERROR }
    end
  end
end
