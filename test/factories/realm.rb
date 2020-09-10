FactoryBot.define do
  factory :realm do
    sequence(:name) { |n| "EXAMPLE#{n}.COM" }
    realm_type { Realm::TYPES.first }
    association :realm_proxy, :factory => :realm_smart_proxy
  end
end
