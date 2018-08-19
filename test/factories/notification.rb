FactoryBot.define do
  factory :notification do
    notification_blueprint
    association :initiator, :factory => :user
    audience { 'user' }
    subject { User.first }
  end
end
