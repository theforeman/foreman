FactoryBot.define do
  factory :setting do
    category               { 'Setting' }
    sequence(:name)        { |n| "setting#{n}" }
  end
end
