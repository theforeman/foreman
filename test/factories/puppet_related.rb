FactoryGirl.define do
  factory :environment do
    sequence(:name) {|n| "environment#{n}" }
  end

  factory :environment_class

  factory :lookup_key do
    sequence(:key) {|n| "param#{n}" }

    ignore do
      overrides({})
    end
    after_create do |lkey,evaluator|
      evaluator.overrides.each do |match,value|
        FactoryGirl.create :lookup_value, :lookup_key_id => lkey.id, :value => value, :match => match
      end
      lkey.reload
    end

    trait :with_override do
      override true
      default_value "default value"
      path "comment"
      overrides({"comment=override" => "overridden value"})
    end

    trait :as_smart_class_param do
      is_param true
      ignore do
        puppetclass nil
      end
      after_create do |lkey,evaluator|
        evaluator.puppetclass.environments.each do |env|
          FactoryGirl.create :environment_class, :puppetclass_id => evaluator.puppetclass.id, :environment_id => env.id, :lookup_key_id => lkey.id
        end
      end
    end
  end

  factory :lookup_value

  factory :puppetclass do
    sequence(:name) {|n| "class#{n}" }

    ignore do
      environments []
    end
    after_create do |pc,evaluator|
      evaluator.environments.each do |env|
        FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id
      end
    end

    trait :with_parameters do
      ignore do
        parameter_count 1
      end
      after_create do |pc,evaluator|
        evaluator.parameter_count.times do
          evaluator.environments.each do |env|
            lkey = FactoryGirl.create :lookup_key, :is_param => true
            FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id, :lookup_key_id => lkey.id
          end
        end
      end
    end
  end
end
