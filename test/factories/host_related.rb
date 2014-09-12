FactoryGirl.define do
  factory :host do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "host#{n}" }
    sequence(:ip) { |n| IPAddr.new(n, Socket::AF_INET).to_s }
    sequence(:mac) { |n| "01:23:45:67:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    root_pass 'xybxa6JUkz63w'
    domain
    environment

    trait :with_medium do
      medium
    end

    trait :with_hostgroup do
      hostgroup { FactoryGirl.create(:hostgroup, :environment => environment) }
    end

    trait :with_puppetclass do
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end

    trait :with_config_group do
      config_groups { [ FactoryGirl.create(:config_group, :with_puppetclass, :class_environments => [environment]) ] }
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

    trait :with_operatingsystem do
      operatingsystem
    end

    trait :with_puppet do
      puppet_proxy { FactoryGirl.create(:smart_proxy,
                        :features => [FactoryGirl.create(:feature, :puppet)])
      }
    end

    trait :managed do
      managed true
      architecture
      medium
      ptable
      location
      organization
      operatingsystem { FactoryGirl.create(:operatingsystem,
                          :architectures => [architecture],
                          :ptables => [ptable],
                          :media => [medium])
      }
    end

    trait :with_dhcp_orchestration do
      managed true
      architecture
      association :compute_resource, :factory => :libvirt_cr
      ptable
      operatingsystem { FactoryGirl.create(:operatingsystem,
                          :architectures => [architecture], :ptables => [ptable])
      }
      subnet {
        FactoryGirl.create(
          :subnet,
          :dhcp => FactoryGirl.create(:smart_proxy,
                     :features => [FactoryGirl.create(:feature, :dhcp)])
        )
      }
      ip { subnet.network.sub(/0\Z/, '1') }
    end

    trait :with_dns_orchestration do
      managed true
      architecture
      association :compute_resource, :factory => :libvirt_cr
      ptable
      operatingsystem { FactoryGirl.create(:operatingsystem,
                          :architectures => [architecture], :ptables => [ptable])
      }
      subnet {
        FactoryGirl.create(:subnet,
          :dns => FactoryGirl.create(:smart_proxy,
                    :features => [FactoryGirl.create(:feature, :dns)])
        )
      }
      domain {
        FactoryGirl.create(:domain,
          :dns => FactoryGirl.create(:smart_proxy,
                    :features => [FactoryGirl.create(:feature, :dns)])
        )
      }
      ip { subnet.network.sub(/0\Z/, '1') }
    end

    trait :with_puppet_orchestration do
      managed true
      architecture
      location
      organization
      association :compute_resource, :factory => :libvirt_cr
      ptable
      operatingsystem { FactoryGirl.create(:operatingsystem,
                                           :architectures => [architecture], :ptables => [ptable] )
      }
      puppet_ca_proxy { FactoryGirl.create(:smart_proxy,
                                            :features => [FactoryGirl.create(:feature, :puppetca)])
      }
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

  factory :ptable do
    sequence(:name) { |n| "ptable#{n}" }
    layout 'zerombr yes\nclearpart --all    --initlabel\npart /boot --fstype ext3 --size=<%= 10 * 10 %> --asprimary\npart /     --f   stype ext3 --size=1024 --grow\npart swap  --recommended'
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
    sequence(:mac) { |n| "00:00:00:00:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
  end
  factory :nic_interface, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::Interface'
  end
  factory :nic_managed, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::Managed'
    sequence(:mac) { |n| "01:23:45:ab:cd:" + n.to_s(16).rjust(2, '0') }
  end
  factory :nic_bmc, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::BMC'
    sequence(:mac) { |n| "01:23:45:ab:ef:" + n.to_s(16).rjust(2, '0') }
  end
  factory :nic_bond, :class => Nic::Bond, :parent => :nic_base do
    type 'Nic::Bond'
    mode 'balance-rr'
  end
end
