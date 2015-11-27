# Helpers

def deferred_nic_attrs
  [:ip, :mac, :subnet, :domain]
end

def set_nic_attributes(host, attributes, evaluator)
  attributes.each do |nic_attribute|
    next unless evaluator.send(nic_attribute).present?
    host.primary_interface.send(:"#{nic_attribute}=", evaluator.send(nic_attribute))
  end
  host
end

FactoryGirl.define do
  factory :ptable do
    sequence(:name) { |n| "ptable#{n}" }
    layout 'zerombr\nclearpart --all    --initlabel\npart /boot --fstype ext3 --size=<%= 10 * 10 %> --asprimary\npart /     --f   stype ext3 --size=1024 --grow\npart swap  --recommended'
    os_family 'Redhat'

    trait :ubuntu do
      sequence(:name) { |n| "ubuntu default#{n}" }
      layout "d-i partman-auto/disk string /dev/sda\nd-i partman-auto/method string regular..."
      os_family 'Debian'
    end

    trait :suse do
      sequence(:name) { |n| "suse default#{n}" }
      layout "<partitioning  config:type=\"list\">\n  <drive>\n    <device>/dev/hda</device>\n    <use>all</use>\n  </drive>\n</partitioning>"
      os_family 'Suse'
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

  factory :nic_base, :class => Nic::Base do
    type 'Nic::Base'
    sequence(:identifier) { |n| "eth#{n}" }
    sequence(:mac) { |n| "00:00:00:00:" + n.to_s(16).rjust(4, '0').insert(2, ':') }

    trait :with_subnet do
      subnet do
        FactoryGirl.build(:subnet,
          :organizations => host ? [host.organization] : [],
          :locations => host ? [host.location] : [])
      end
    end
  end

  factory :nic_interface, :class => Nic::Interface, :parent => :nic_base do
    type 'Nic::Interface'
  end

  factory :nic_managed, :class => Nic::Managed, :parent => :nic_interface do
    type 'Nic::Managed'
    sequence(:mac) { |n| "01:23:45:ab:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new(n, Socket::AF_INET).to_s }
  end

  factory :nic_bmc, :class => Nic::BMC, :parent => :nic_managed do
    type 'Nic::BMC'
    sequence(:mac) { |n| "01:23:56:cd:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new(255 + n, Socket::AF_INET).to_s }
    provider 'IPMI'
    username 'admin'
    password 'admin'
  end

  factory :nic_bond, :class => Nic::Bond, :parent => :nic_managed do
    type 'Nic::Bond'
    mode 'balance-rr'
  end

  factory :nic_bridge, :class => Nic::Bridge, :parent => :nic_managed do
    type 'Nic::Bridge'
  end

  factory :nic_primary_and_provision, :parent => :nic_managed, :class => Nic::Managed do
    primary true
    provision true
    sequence(:mac) { |n| "01:23:67:ab:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new(n, Socket::AF_INET).to_s }
  end

  factory :model do
    sequence(:name) { |n| "hal900#{n}" }
  end

  factory :host do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "host#{n}" }
    root_pass 'xybxa6JUkz63w'

    # This allows a test to declare build/create(:host, :ip => '1.2.3.4') and
    # have the primary interface correctly updated with the specified attrs
    after(:build) do |host,evaluator|
      unless host.primary_interface.present?
        opts = {
          :primary => true,
          :domain  => FactoryGirl.build(:domain)
        }
        host.interfaces << FactoryGirl.build(:nic_managed, opts)
      end

      set_nic_attributes(host, deferred_nic_attrs, evaluator)
    end

    trait :with_environment do
      environment
    end

    trait :with_medium do
      medium
    end

    trait :with_hostgroup do
      hostgroup { FactoryGirl.create(:hostgroup, :environment => environment) }
    end

    trait :with_puppetclass do
      environment
      puppetclasses { [ FactoryGirl.create(:puppetclass, :environments => [environment]) ] }
    end

    trait :with_config_group do
      config_groups { [ FactoryGirl.create(:config_group, :with_puppetclass, :class_environments => [environment]) ] }
    end

    trait :with_parameter do
      after(:create) do |host,evaluator|
        FactoryGirl.create(:host_parameter, :host => host)
      end
    end

    trait :with_facts do
      transient do
        fact_count 20
      end
      after(:create) do |host,evaluator|
        evaluator.fact_count.times do
          FactoryGirl.create(:fact_value, :host => host)
        end
      end
    end

    trait :with_reports do
      transient do
        report_count 5
      end
      after(:create) do |host,evaluator|
        evaluator.report_count.times do
          FactoryGirl.create(:report, :host => host)
        end
      end
    end

    trait :on_compute_resource do
      uuid Foreman.uuid
      association :compute_resource, :factory => :ec2_cr
      after(:build) { |host| host.class.skip_callback(:validation, :after, :queue_compute) }
    end

    trait :with_subnet do
      after(:build) do |host|
        overrides = {}
        overrides[:locations] = [host.location] unless host.location.nil?
        overrides[:organizations] = [host.organization] unless host.organization.nil?
        host.subnet = FactoryGirl.build(:subnet, overrides)
      end
    end

    trait :with_operatingsystem do
      operatingsystem
    end

    trait :with_puppet do
      environment
      puppet_proxy do
        FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, :puppet)])
      end
    end

    trait :managed do
      managed true
      architecture { operatingsystem.try(:architectures).try(:first) }
      medium { operatingsystem.try(:media).try(:first) }
      ptable { operatingsystem.try(:ptables).try(:first) }
      location
      organization
      domain
      interfaces { [ FactoryGirl.build(:nic_primary_and_provision) ] }
      association :operatingsystem, :with_associations
    end

    trait :with_dhcp_orchestration do
      managed
      association :compute_resource, :factory => :libvirt_cr
      domain
      subnet do
        overrides = {
          :dhcp => FactoryGirl.create(:smart_proxy,
                     :features => [FactoryGirl.create(:feature, :dhcp)])
        }
        #add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?
        FactoryGirl.create(
          :subnet,
          overrides
        )
      end
      interfaces do
        [FactoryGirl.build(:nic_primary_and_provision, :ip => subnet.network.sub(/0\Z/, '1'))]
      end
    end

    trait :with_dns_orchestration do
      managed
      association :compute_resource, :factory => :libvirt_cr
      subnet do
        overrides = {:dns => FactoryGirl.create(:smart_proxy,
                                                :features => [FactoryGirl.create(:feature, :dns)])}
        #add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?

        FactoryGirl.create(:subnet, overrides)
      end
      domain do
        FactoryGirl.create(:domain,
          :dns => FactoryGirl.create(:smart_proxy,
                    :features => [FactoryGirl.create(:feature, :dns)])
        )
      end
      interfaces do
        [FactoryGirl.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryGirl.build(:domain),
                                         :ip => subnet.network.sub(/0\Z/, '1'))]
      end
    end

    trait :with_tftp_subnet do
      subnet { FactoryGirl.build(:subnet, :tftp, locations: [location], organizations: [organization]) }
    end

    trait :with_tftp_orchestration do
      managed
      with_tftp_subnet
      interfaces do
        [FactoryGirl.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryGirl.build(:domain),
                                         :subnet => subnet,
                                         :ip => subnet.network.sub(/0\Z/, '2'))]
      end
    end

    trait :with_puppet_orchestration do
      managed
      environment
      association :compute_resource, :factory => :libvirt_cr
      domain
      interfaces { [ FactoryGirl.build(:nic_primary_and_provision) ] }
      puppet_ca_proxy do
        FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, :puppetca)])
      end
    end

    trait :with_realm do
      realm
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
      after(:create) do |hg,evaluator|
        FactoryGirl.create(:hostgroup_parameter, :hostgroup => hg)
      end
    end

    trait :with_subnet do
      subnet
    end

    trait :with_rootpass do
      sequence(:root_pass) { |n| "xybxa6JUkz63#{n}" }
    end

    trait :with_os do
      architecture { operatingsystem.try(:architectures).try(:first) }
      medium { operatingsystem.try(:media).try(:first) }
      ptable { operatingsystem.try(:ptables).try(:first) }
      association :operatingsystem, :with_associations
    end

    trait :with_puppet_orchestration do
      architecture
      ptable
      operatingsystem do
        FactoryGirl.create(:operatingsystem, :architectures => [architecture], :ptables => [ptable])
      end
      puppet_ca_proxy do
        FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, :puppetca)])
      end
      puppet_proxy do
        FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, :puppet)])
      end
    end
  end
end
