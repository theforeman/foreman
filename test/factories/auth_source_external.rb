FactoryBot.define do
  factory :auth_source_external do
    sequence(:name) { |n| "auth_source_external_#{n}" }
  end
end
