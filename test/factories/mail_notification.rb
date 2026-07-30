FactoryBot.define do
  factory :mail_notification do
    sequence(:name) { |n| "notification#{n}" }
    default_interval { "Daily" }
    mailer { "HostMailer" }
    mailer_method { "test_mail" }
    description { "Notifies a user" }
    subscription_type { "report" }
    queryable { false }
    skippable { false }

    trait :queryable do
      queryable { true }
    end

    trait :skippable do
      skippable { true }
    end

    trait :alert do
      subscription_type { "alert" }
    end

    trait :config_error do
      sequence(:name) { "config_error_state" }
      mailer { "HostMailer" }
      mailer_method { "config" }
      type { "ConfigManagementError" }
    end
  end

  factory :user_mail_notification do
    user
    mail_notification
    interval { "Daily" }
  end
end
