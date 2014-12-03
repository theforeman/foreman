FactoryGirl.define do
  factory :environment do
    sequence(:name) {|n| "environment#{n}" }
  end

  factory :environment_class

  factory :lookup_key do
    sequence(:key) {|n| "param#{n}" }

    transient do
      overrides({})
    end
    after(:create) do |lkey,evaluator|
      evaluator.overrides.each do |match,value|
        FactoryGirl.create :lookup_value, :lookup_key_id => lkey.id, :value => value, :match => match, :use_puppet_default => false
      end
      lkey.reload
    end

    trait :is_param do
      is_param true
    end

    trait :with_override do
      override true
      default_value "default value"
      path "comment"
      overrides({"comment=override" => "overridden value"})
    end

    trait :as_smart_class_param do
      is_param true
      transient do
        puppetclass nil
      end
      after(:create) do |lkey,evaluator|
        evaluator.puppetclass.environments.each do |env|
          FactoryGirl.create :environment_class, :puppetclass_id => evaluator.puppetclass.id, :environment_id => env.id, :lookup_key_id => lkey.id
        end
      end
    end

    trait :with_use_puppet_default do
      use_puppet_default true
    end
  end

  factory :lookup_value

  factory :puppetclass do
    sequence(:name) {|n| "class#{n}" }

    transient do
      environments []
    end
    after(:create) do |pc,evaluator|
      evaluator.environments.each do |env|
        FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id
      end
    end

    trait :with_parameters do
      transient do
        parameter_count 1
      end
      after(:create) do |pc,evaluator|
        evaluator.parameter_count.times do
          evaluator.environments.each do |env|
            lkey = FactoryGirl.create :lookup_key, :is_param => true
            FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id, :lookup_key_id => lkey.id
          end
        end
      end
    end
  end

  factory :config_group do
    sequence(:name) {|n| "config_group#{n}" }
    transient do
      class_environments nil
    end

    trait :with_puppetclass do
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => class_environments) ] }
    end
  end

end
