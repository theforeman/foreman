FactoryBot.define do
  factory :environment do
    sequence(:name) { |n| "environment#{n}" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :for_snapshots_test do
      name { 'test' }
    end
  end

  factory :config_group do
    sequence(:name) { |n| "config_group#{n}" }
  end
end
