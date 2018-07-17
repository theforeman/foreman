FactoryBot.define do
  factory :provisioning_template do
    sequence(:name) { |n| "provisioning_template#{n}" }
    sequence(:template) { |n| "template content #{n}" }

    template_kind

    trait :snippet do
      snippet { true }
      template_kind { nil }
    end

    trait :with_input do
      after(:build) do |template, evaluator|
        template.template_inputs << FactoryBot.build(:template_input)
      end
    end
  end

  factory :template_combination do
    provisioning_template
    hostgroup
    environment
  end

  factory :os_default_template do
    template_kind
    provisioning_template { FactoryBot.create(:provisioning_template, :template_kind => template_kind) }
    operatingsystem { FactoryBot.create(:operatingsystem, :provisioning_templates => [provisioning_template]) }
  end

  factory :template_kind do
    sequence(:name) { |n| "template_kind_#{n}" }
  end
end
