FactoryBot.define do
  factory :report_template do
    sequence(:name) { |n| "report_template#{n}" }
    sequence(:template) { |n| "template content #{n}" }

    trait :snippet do
      snippet true
    end
  end
end
