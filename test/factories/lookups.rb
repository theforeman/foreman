FactoryBot.define do
  factory :lookup_key, class: 'LookupKey' do
    transient do
      overrides { {} }
    end

    sequence(:key) { |n| "param#{n}" }
    key_type { 'string' }
    path { nil }
    default_value { 'default' }

    trait :integer do
      key_type { 'integer' }
      default_value { 1 }
    end

    trait :boolean do
      key_type { 'boolean' }
      default_value { true }
    end

    trait :yaml do
      key_type { 'yaml' }
      default_value { '--- \nfoo: bar\n' }
    end

    trait :array do
      key_type { 'array' }
      default_value { '[{"hostname": "test.example.com"}]' }
    end

    trait :hash do
      key_type { 'hash' }
      default_value { '{"hostname": "test.example.com"}' }
    end

    trait :with_omit do
      omit { true }
    end

    trait :with_override do
      override { true }
      path { 'comment' }
      overrides do
        {
          'comment=override' => case key_type
                                when 'integer'
                                  2
                                when 'boolean'
                                  false
                                when 'yaml'
                                  '--- \nfoo: overridden\n'
                                when 'array'
                                  '[{"overridden": "value"}]'
                                when 'hash'
                                  '{"overridden": "value"}'
                                else
                                  'overridden value'
                                end,
        }
      end
    end

    after(:create) do |lkey, evaluator|
      evaluator.overrides.each do |match, value|
        FactoryBot.create :lookup_value, :lookup_key => lkey, :value => value, :match => match, :omit => false
      end
      lkey.reload
    end
  end

  factory :lookup_value do
    association :lookup_key
    sequence(:value) { |n| "value#{n}" }
    omit { false }

    trait :with_omit do
      omit { true }
    end
  end
end
