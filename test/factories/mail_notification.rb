FactoryGirl.define do
  factory :mail_notification do
    sequence(:name) {|n| "notification#{n}"}
    default_interval "Daily"
    mailer "HostMailer"
    mailer_method "test_mail"
    description "Notifies a user"
    subscription_type "report"
  end
end

