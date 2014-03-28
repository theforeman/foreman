FactoryGirl.define do
  factory :host do
    sequence(:name) { |n| "host#{n}" }
    domain
    environment

    trait :with_hostgroup do
      hostgroup :environment => environment
    end

    trait :with_puppetclass do
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end
  end

  factory :hostgroup do
    sequence(:name) { |n| "hostgroup#{n}" }

    trait :with_parent do
      association :parent, :factory => :hostgroup
    end

    trait :with_puppetclass do
      environment
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end
  end
end
