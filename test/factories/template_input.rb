FactoryBot.define do
  factory :template_input do |f|
    f.sequence(:name) { |n| "Template input #{n}" }
    f.input_type { 'user' }
    f.value_type { 'plain' }
    f.resource_type {}
  end
end
