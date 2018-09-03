FactoryBot.define do
  factory :bookmark do
    sequence(:name) { |n| "bookmark_#{n}" }
    query { "bar" }

    public { false }
  end
end
