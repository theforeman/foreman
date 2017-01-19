FactoryGirl.define do
  factory :notification do
    notification_type
    association :initiator, :factory => :user
  end
end
