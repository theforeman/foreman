FactoryBot.define do
  factory :organization_parameter, :parent => :parameter, :class => OrganizationParameter do
    type { 'OrganizationParameter' }
  end

  factory :organization do
    sequence(:name) { |n| "org#{n}" }

    trait :with_parameter do
      after(:create) do |organization, evaluator|
        FactoryBot.create(:organization_parameter, :organization => organization)
      end
    end
  end

  factory :location_parameter, :parent => :parameter, :class => LocationParameter do
    type { 'LocationParameter' }
  end

  factory :location do
    sequence(:name) { |n| "loc#{n}" }

    trait :with_parameter do
      after(:create) do |location, evaluator|
        FactoryBot.create(:location_parameter, :location => location)
      end
    end
  end
end
