FactoryGirl.define do
  factory :environment do
    sequence(:name) {|n| "environment#{n}" }
  end

  factory :environment_class

  factory :puppetclass do
    sequence(:name) {|n| "class#{n}" }

    ignore do
      environments []
    end

    after_create do |pc,evaluator|
      evaluator.environments.each do |env|
        FactoryGirl.create :environment_class, :puppetclass_id => pc.id, :environment_id => env.id
      end
    end
  end
end
