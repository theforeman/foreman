FactoryGirl.define do
  factory :environment do
    sequence(:name) {|n| "environment#{n}" }
    organizations []
    locations []
  end

  factory :environment_class

  FactoryGirl.define do
    factory :lookup_key, class: 'LookupKey' do
      sequence(:key) { |n| "param#{n}" }
    end

    factory :puppetclass_lookup_key, parent: :lookup_key, class: 'PuppetclassLookupKey' do
      puppet_default_value ''
      transient do
        overrides({})
      end
      after(:create) do |lkey, evaluator|
        evaluator.overrides.each do |match, value|
          FactoryGirl.create :lookup_value, :lookup_key_id => lkey.id, :value => value, :match => match, :omit => false
        end
        lkey.reload
      end

      trait :with_override do
        override true
        key_type "string"
        path "comment"
        overrides({ "comment=override" => "overridden value" })
        after(:build) do |lkey|
          lkey.build_default_value
          lkey.default.value = "default value" if lkey.default.value.nil?
        end
      end

      trait :as_smart_class_param do
        transient do
          puppetclass nil
        end
        after(:create) do |lkey, evaluator|
          evaluator.puppetclass.environments.each do |env|
            FactoryGirl.create :environment_class, :puppetclass_id => evaluator.puppetclass.id, :environment_id => env.id, :puppetclass_lookup_key_id => lkey.id
          end
        end
      end

      trait :with_omit do
        after(:build) do |lkey|
          lkey.build_default_value
          lkey.default.omit = true
        end
      end
    end

    factory :variable_lookup_key, parent: :lookup_key, class: 'VariableLookupKey' do
      transient do
        overrides({})
      end
      after(:create) do |lkey, evaluator|
        evaluator.overrides.each do |match, value|
          FactoryGirl.create :lookup_value, :lookup_key_id => lkey.id, :value => value, :match => match
        end
        lkey.reload
      end

      trait :with_override do
        default "default value"
        path "comment"
        overrides({ "comment=override" => "overridden value" })
      end
    end
  end

  factory :lookup_value do
    sequence(:value) {|n| "value#{n}" }

    trait :with_omit do
      omit true
    end
  end

  factory :puppetclass do
    sequence(:name) {|n| "class#{n}" }

    transient do
      environments []
    end
    after(:create) do |pc,evaluator|
      evaluator.environments.each do |env|
        FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id unless env.nil?
      end
    end

    trait :with_parameters do
      transient do
        parameter_count 1
      end
      after(:create) do |pc,evaluator|
        evaluator.parameter_count.times do
          evaluator.environments.each do |env|
            lkey = FactoryGirl.create :puppetclass_lookup_key
            FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id, :puppetclass_lookup_key_id => lkey.id
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
