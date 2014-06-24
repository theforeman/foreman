FactoryGirl.define do
  factory :config_template do
    sequence(:name) { |n| "config_template#{n}" }
    sequence(:template) { |n| "template content #{n}" }

    template_kind
  end

  factory :template_combination do
    config_template
    hostgroup
    environment
  end

  factory :os_default_template do
    config_template
    operatingsystem
    template_kind
  end

  factory :template_kind do
    sequence(:name) { |n| "template_kind_#{n}" }
  end
end
