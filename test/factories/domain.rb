FactoryGirl.define do
  factory :domain_parameter, :parent => :parameter, :class => DomainParameter do
    type 'DomainParameter'
  end

  factory :domain do
    sequence(:name) {|n| "example#{n}.com" }
    fullname { |n| n.name }
    organizations { [Organization.find_by_name('Organization 1')] } if SETTINGS[:organizations_enabled]
    locations { [Location.find_by_name('Location 1')] } if SETTINGS[:locations_enabled]

    trait :with_parameter do
      after(:create) do |domain,evaluator|
        FactoryGirl.create(:domain_parameter, :domain => domain)
      end
    end
  end
end
