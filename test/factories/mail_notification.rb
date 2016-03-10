FactoryGirl.define do
  factory :mail_notification do
    ignore do
      sequence(:name) {|n| "notification#{n}"}
      default_interval "Daily"
      mailer "HostMailer"
      mailer_method "test_mail"
      description "Notifies a user"
      subscription_type "report"
      queryable false
    end

    trait :puppet_error do
      sequence(:name) {"puppet_error_state"}
      mailer "HostMailer"
      mailer_method "puppet"
    end

    initialize_with { MailNotification.new ({:name => name, :mailer => mailer, :mailer_method => mailer_method} )  }
  end
end
