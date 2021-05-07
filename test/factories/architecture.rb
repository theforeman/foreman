FactoryBot.define do
  factory :architecture do
    sequence(:name) { |n| "x86_64-#{n}" }

    trait :for_snapshots_x86_64 do
      name { 'x86_64' }
    end
  end
end
