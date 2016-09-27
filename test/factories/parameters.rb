FactoryGirl.define do
  factory :global_lookup_key, parent: :lookup_key, class: 'GlobalLookupKey' do
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
      override true
    end
  end
end
