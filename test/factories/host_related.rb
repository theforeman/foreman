FactoryGirl.define do
  factory :host do
    sequence(:name) { |n| "host#{n}" }
    domain
    environment

    trait :with_hostgroup do
      hostgroup :environment => environment
    end

    trait :with_puppetclass do
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end

    trait :with_parameter do
      after_create do |host,evaluator|
        FactoryGirl.create(:host_parameter, :host => host)
      end
    end

    trait :on_compute_resource do
      uuid Foreman.uuid
      association :compute_resource, :factory => :ec2_cr
      after_build { |host| host.class.skip_callback(:validation, :after, :queue_compute) }
    end
  end

  factory :hostgroup do
    sequence(:name) { |n| "hostgroup#{n}" }

    trait :with_parent do
      association :parent, :factory => :hostgroup
    end

    trait :with_puppetclass do
      environment
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end

    trait :with_parameter do
      after_create do |hg,evaluator|
        FactoryGirl.create(:hostgroup_parameter, :hostgroup => hg)
      end
    end
  end

  factory :parameter do
    sequence(:name) { |n| "parameter#{n}" }
    sequence(:value) { |n| "parameter value #{n}" }
    type 'CommonParameter'
  end
  factory :host_parameter, :parent => :parameter, :class => HostParameter do
    type 'HostParameter'
  end
  factory :hostgroup_parameter, :parent => :parameter, :class => GroupParameter do
    type 'GroupParameter'
  end
end
