FactoryBot.define do
  factory :environment do
    sequence(:name) { |n| "environment#{n}" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }
  end

  factory :environment_class do
    environment
    puppetclass
  end

  factory :puppetclass_lookup_key, parent: :lookup_key, class: 'PuppetclassLookupKey' do
    trait :as_smart_class_param do
      transient do
        puppetclass { nil }
      end
      after(:create) do |lkey, evaluator|
        evaluator.puppetclass&.environments&.each do |env|
          FactoryBot.create :environment_class, :puppetclass => evaluator.puppetclass, :environment => env, :puppetclass_lookup_key_id => lkey.id
        end
      end
    end
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

    trait :with_parameters do
      transient do
        parameter_count { 1 }
      end
      after(:create) do |pc, evaluator|
        evaluator.parameter_count.times do
          evaluator.environments.each do |env|
            lkey = FactoryBot.create :puppetclass_lookup_key
            FactoryBot.create :environment_class, :puppetclass => pc, :environment => env, :puppetclass_lookup_key_id => lkey.id
          end
        end
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
