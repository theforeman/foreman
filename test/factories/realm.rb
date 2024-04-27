FactoryBot.define do
  factory :realm do
    sequence(:name) { |n| "EXAMPLE#{n}.COM" }
    realm_type { Realm::TYPES.first }
    association :realm_proxy, :factory => [:smart_proxy, :realm]
  end
end
