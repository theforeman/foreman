FactoryBot.define do
  factory :environment do
    sequence(:name) { |n| "environment#{n}" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :for_snapshots_test do
      name { 'test' }
    end
  end

  factory :environment_class do
    environment
    puppetclass
  end

  factory :puppetclass do
    sequence(:name) { |n| "class#{n}" }

    transient do
      environments { [] }
    end
    after(:create) do |pc, evaluator|
      evaluator.environments.each do |env|
        FactoryBot.create :environment_class, :puppetclass => pc, :environment => env unless env.nil?
      end
    end
  end

  factory :config_group do
    sequence(:name) { |n| "config_group#{n}" }
    transient do
      class_environments { nil }
    end

    trait :with_puppetclass do
      puppetclasses { [FactoryBot.create(:puppetclass, :environments => class_environments)] }
    end
  end
end
