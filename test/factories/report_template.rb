FactoryBot.define do
  factory :report_template do
    sequence(:name) { |n| "report_template#{n}" }
    sequence(:template) { |n| "template content #{n}" }

    trait :with_input do
      after(:build) do |template, evaluator|
        template.template_inputs << FactoryBot.build(:template_input)
      end
    end

    trait :snippet do
      snippet { true }
    end

    trait :locked do
      locked { true }
    end

    trait :with_report_render do
      template { "<%= report_render -%>" }
    end
  end
end
