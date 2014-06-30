FactoryGirl.define do
  factory :host do
    sequence(:name) { |n| "host#{n}" }
    domain
    environment

    trait :with_medium do
      medium
    end

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

    trait :with_facts do
      ignore do
        fact_count 20
      end
      after_create do |host,evaluator|
        evaluator.fact_count.times do
          FactoryGirl.create(:fact_value, :host => host)
        end
      end
    end

    trait :with_reports do
      ignore do
        report_count 5
      end
      after_create do |host,evaluator|
        evaluator.report_count.times do
          FactoryGirl.create(:report, :host => host)
        end
      end
    end

    trait :on_compute_resource do
      uuid Foreman.uuid
      association :compute_resource, :factory => :ec2_cr
      after_build { |host| host.class.skip_callback(:validation, :after, :queue_compute) }
    end

    trait :with_subnet do
      subnet
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

    trait :with_config_group do
      environment
      config_groups { [ FactoryGirl.create(:config_group, :with_puppetclass, :class_environments => [environment]) ] }
    end

    trait :with_parameter do
      after_create do |hg,evaluator|
        FactoryGirl.create(:hostgroup_parameter, :hostgroup => hg)
      end
    end

    trait :with_subnet do
      subnet
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
  factory :nic_base do
    sequence(:identifier) { |n| "eth#{n}" }
  end
  factory :nic_interface, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::Interface'
  end
  factory :nic_managed, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::Managed'
  end
  factory :nic_bmc, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::BMC'
  end
end
