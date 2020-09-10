FactoryBot.define do
  factory :stored_value do
    sequence(:key) { |n| "UNIQUE-KEY-#{n}" }
    value { 'MyValue' }
    expire_at { Time.now + 1.hour }
  end
end
