FactoryBot.define do
  factory :audit do
    sequence(:version) { |n| n.to_s }
    auditable_type { "test" }
    action { "update" }

    trait :with_diff do
      transient do
        old_template { "old\ntemplate" }
        new_template { "new\ntemplate" }
      end

      audited_changes do
        {'template' => [old_template, new_template]}
      end
    end
  end
end
