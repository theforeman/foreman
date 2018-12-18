FactoryBot.define do
  factory :bookmark do
    sequence(:name) { |n| "bookmark_#{n}" }
    query { "bar" }
    # rubocop:disable Layout/EmptyLinesAroundAccessModifier
    public { false }
    # rubocop:enable Layout/EmptyLinesAroundAccessModifier
  end
end
