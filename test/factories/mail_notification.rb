FactoryGirl.define do
  factory :mail_notification do
    sequence(:name)  {|n| "Notification#{n}" }
    sequence(:title) {|n| "notification#{n}".to_sym }
    default_interval "daily"
    mailer "HostMailer"
    method "test_mail"
    description "Notifies a user"
  end
end

