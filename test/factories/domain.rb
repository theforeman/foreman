FactoryBot.define do
  factory :domain_parameter, :parent => :parameter, :class => DomainParameter do
    type { 'DomainParameter' }
  end

  factory :domain do
    sequence(:name) { |n| "example#{n}.com" }
    fullname { |n| n.name }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :with_parameter do
      after(:create) do |domain, evaluator|
        FactoryBot.create(:domain_parameter, :domain => domain)
      end
    end

    factory :domain_for_snapshots do
      name { 'snap.example.com' }
      fullname { 'snap.example.com' }
    end
  end
end
