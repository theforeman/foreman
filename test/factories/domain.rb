FactoryGirl.define do
  factory :domain_parameter, :parent => :parameter, :class => DomainParameter do
    type 'DomainParameter'
  end

  factory :domain do
    sequence(:name) {|n| "example#{n}.com" }
    fullname { |n| n.name }

    trait :with_parameter do
      after(:create) do |domain,evaluator|
        FactoryGirl.create(:domain_parameter, :domain => domain)
      end
    end
  end
end
