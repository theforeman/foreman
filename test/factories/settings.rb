FactoryBot.define do
  factory :setting do
    settings_type          { 'string' }
    category               { 'Setting' }
    sequence(:name)        { |n| "setting#{n}" }
    sequence(:default)     { |n| "default#{n}" }
    sequence(:description) { |n| "description#{n}" }
  end
end
