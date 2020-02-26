FactoryBot.define do
  factory :key_pair do
    sequence(:name) { |n| "foreman-#{n}" }
    secret { "--- BEGIN RSA Blah blah #{Foreman.uuid}" }
    association :compute_resource, factory: :ec2_cr
  end
end
