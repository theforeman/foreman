FactoryGirl.define do
  factory :notification do
    notification_blueprint
    association :initiator, :factory => :user
    audience 'user'
  end
end
