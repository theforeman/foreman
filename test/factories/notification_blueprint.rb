FactoryBot.define do
  factory :notification_blueprint do
    sequence(:group) { |n| "notification_blueprint_#{n}" }
    sequence(:message) { |n| "message_#{n}" }
    sequence(:name) { |n| "name_#{n}" }
    level { 'info' }
    expires_in { 24.hours }
  end
end
