FactoryGirl.define do
  factory :notification_type do
    sequence(:name) { |n| "notification_type_#{n}" }
    sequence(:message) { |n| "message_#{n}" }
    audience 'user'
    level 'info'
    expires_in 24.hours
  end
end
