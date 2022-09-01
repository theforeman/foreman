# Helpers

def deferred_nic_attrs
  [:ip, :ip6, :mac, :subnet, :domain]
end

def set_nic_attributes(host, attributes, evaluator)
  attributes.each do |nic_attribute|
    next unless evaluator.send(nic_attribute).present?
    host.primary_interface.send(:"#{nic_attribute}=", evaluator.send(nic_attribute))
  end
  host
end

FactoryBot.define do
  factory :ptable do
    sequence(:name) { |n| "ptable#{n}" }
    layout { "zerombr\nclearpart --all    --initlabel\npart /boot --fstype ext3 --size=<%= 10 * 10 %> --asprimary\npart /     --fstype ext3 --size=1024 --grow\npart swap  --recommended" }
    os_family { 'Redhat' }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :ubuntu do
      sequence(:name) { |n| "ubuntu default#{n}" }
      layout { "d-i partman-auto/disk string /dev/sda\nd-i partman-auto/method string regular..." }
      os_family { 'Debian' }
    end

    trait :ubuntu_autoinstall do
      sequence(:name) { |n| "ubuntu default autoinstall#{n}" }
      layout { "storage:\n  layout:\n    name: lvm\n" }
      os_family { 'Debian' }
    end

    trait :suse do
      sequence(:name) { |n| "suse default#{n}" }
      layout { "<partitioning  config:type=\"list\">\n  <drive>\n    <device>/dev/hda</device>\n    <use>all</use>\n  </drive>\n</partitioning>" }
      os_family { 'Suse' }
    end
  end

  factory :parameter do
    sequence(:name) { |n| "parameter#{n}" }
    sequence(:value) { |n| "parameter value #{n}" }
    type { 'CommonParameter' }
  end

  factory :host_parameter, :parent => :parameter, :class => HostParameter do
    type { 'HostParameter' }
  end

  factory :hostgroup_parameter, :parent => :parameter, :class => GroupParameter do
    type { 'GroupParameter' }
  end

  factory :nic_base, :class => Nic::Base do
    type { 'Nic::Base' }
    sequence(:identifier) { |n| "eth#{n}" }
    sequence(:mac) { |n| "00:23:45:ab:" + n.to_s(16).rjust(4, '0').insert(2, ':') }

    trait :with_subnet do
      subnet do
        FactoryBot.build(:subnet_ipv4,
          :organizations => host ? [host.organization] : [],
          :locations => host ? [host.location] : [])
      end
    end
  end

  factory :nic_interface, :class => Nic::Interface, :parent => :nic_base do
    type { 'Nic::Interface' }
  end

  factory :nic_managed, :class => Nic::Managed, :parent => :nic_interface do
    type { 'Nic::Managed' }
    sequence(:mac) { |n| "00:33:45:ab:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new((subnet.present? ? subnet.ipaddr.to_i : 0) + n, Socket::AF_INET).to_s }

    trait :without_ipv4 do
      ip { nil }
    end

    trait :with_ipv6 do
      sequence(:ip6) { |n| Array.new(4) { '%x' % rand(16**4) }.join(':') + '::' + n.to_s }
    end
  end

  factory :nic_bmc, :class => Nic::BMC, :parent => :nic_managed do
    type { 'Nic::BMC' }
    sequence(:mac) { |n| "00:43:56:cd:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new((subnet.present? ? subnet.ipaddr.to_i : 256 * 256 * 256) + n, Socket::AF_INET).to_s }
    provider { 'IPMI' }
    username { 'admin' }
    password { 'admin' }
  end

  factory :nic_bond, :class => Nic::Bond, :parent => :nic_managed do
    type { 'Nic::Bond' }
    mode { 'balance-rr' }
  end

  factory :nic_bridge, :class => Nic::Bridge, :parent => :nic_managed do
    type { 'Nic::Bridge' }
  end

  factory :nic_primary_and_provision, :parent => :nic_managed, :class => Nic::Managed do
    primary { true }
    provision { true }
    sequence(:mac) { |n| "00:53:67:ab:" + n.to_s(16).rjust(4, '0').insert(2, ':') }
    sequence(:ip) { |n| IPAddr.new(n, Socket::AF_INET).to_s }
  end

  factory :model do
    sequence(:name) { |n| "hal900#{n}" }
  end

  factory :host do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "host#{n}" }
    root_pass { 'xybxa6JUkz63w' }
    organization { Organization.find_by_name('Organization 1') }
    location { Location.find_by_name('Location 1') }

    # This allows a test to declare build/create(:host, :ip => '1.2.3.4') and
    # have the primary interface correctly updated with the specified attrs
    after(:build) do |host, evaluator|
      unless host.primary_interface.present?
        opts = {
          :primary => true,
          :domain  => FactoryBot.build(:domain),
        }
        host.interfaces << FactoryBot.build(:nic_managed, opts)
      end

      set_nic_attributes(host, deferred_nic_attrs, evaluator)
    end

    trait :with_build do
      build { true }
    end

    trait :with_model do
      model
    end

    trait :with_medium do
      medium
    end

    trait :with_hostgroup do
      hostgroup { FactoryBot.create(:hostgroup, :with_domain, :with_os) }
    end

    trait :with_config_group do
      config_groups { [FactoryBot.create(:config_group)] }
    end

    trait :with_parameter do
      after(:create) do |host, evaluator|
        FactoryBot.create(:host_parameter, :host => host)
      end
    end

    trait :with_facts do
      transient do
        fact_count { 20 }
      end
      after(:create) do |host, evaluator|
        evaluator.fact_count.times do
          FactoryBot.create(:fact_value, :host => host)
        end
      end
    end

    trait :with_reports do
      transient do
        report_count { 5 }
      end
      after(:create) do |host, evaluator|
        evaluator.report_count.times do |i|
          FactoryBot.create(:report, :host => host, :reported_at => (evaluator.report_count - i).minutes.ago)
        end
        host.update_attribute(:last_report, host.reports.last.reported_at)
      end
    end

    trait :on_compute_resource do
      sequence :uuid do |n|
        Foreman.uuid
      end
      compute_resource do
        taxonomies = {}
        # add taxonomy overrides in case it's set in the host object
        taxonomies[:locations] = [location] unless location.nil?
        taxonomies[:organizations] = [organization] unless organization.nil?
        FactoryBot.create(:ec2_cr, taxonomies)
      end
      before(:create) { |host| host.expects(:queue_compute) }
    end

    trait :with_compute_profile do
      after(:build) do |host|
        host.compute_profile = FactoryBot.create(:compute_profile, :with_compute_attribute, :compute_resource => host.compute_resource)
      end
    end

    trait :with_subnet do
      after(:build) do |host|
        overrides = {}
        overrides[:locations] = [host.location] unless host.location.nil?
        overrides[:organizations] = [host.organization] unless host.organization.nil?
        host.subnet = FactoryBot.build(:subnet_ipv4, overrides)
        host.ip = IPAddr.new(IPAddr.new(host.subnet.network).to_i + 1, Socket::AF_INET).to_s
      end
    end

    trait :with_ipv6_subnet do
      after(:build) do |host|
        overrides = {}
        overrides[:locations] = [host.location] unless host.location.nil?
        overrides[:organizations] = [host.organization] unless host.organization.nil?
        host.subnet6 = FactoryBot.build(:subnet_ipv6, overrides)
      end
    end

    trait :with_operatingsystem do
      operatingsystem
    end

    trait :with_puppet_ca do
      puppet_ca_proxy do
        FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, :puppetca)])
      end
    end

    trait :managed do
      managed { true }
      pxe_loader { "Grub2 UEFI" }
      architecture { operatingsystem.try(:architectures).try(:first) }
      medium { operatingsystem.try(:media).try(:first) }
      ptable { operatingsystem.try(:ptables).try(:first) }
      domain
      interfaces { [FactoryBot.build(:nic_primary_and_provision)] }
      association :operatingsystem, :with_associations
    end

    trait :debian do
      operatingsystem { FactoryBot.build(:debian7_0, :with_associations) }
    end

    trait :suse do
      operatingsystem { FactoryBot.build(:suse, :with_associations) }
    end

    trait :redhat do
      operatingsystem { FactoryBot.build(:rhel7_5, :with_associations) }
    end

    trait :with_ipv6 do
      subnet6 do
        overrides = {:dns => FactoryBot.create(:dns_smart_proxy)}
        # add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?

        FactoryBot.create(:subnet_ipv6, :dns, overrides)
      end
      interfaces do
        [FactoryBot.build(:nic_managed,
          :primary => true,
          :provision => true,
          :domain => FactoryBot.build(:domain),
          :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    trait :dualstack do
      with_ipv6
      subnet do
        overrides = {:dns => FactoryBot.create(:dns_smart_proxy)}
        # add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?

        FactoryBot.create(:subnet_ipv4, overrides)
      end
      interfaces do
        [FactoryBot.build(:nic_managed,
          :primary => true,
          :provision => true,
          :domain => FactoryBot.build(:domain),
          :ip => subnet.network.sub(/0\Z/, '1'),
          :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    factory :host_for_snapshots_base do
      name { 'snapshot-ipv4-dhcp-el7' }
      hostname { name }
      managed { true }
      domain { FactoryBot.build(:domain_for_snapshots) }
      subnet { FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots) }
      pxe_loader { "PXELinux BIOS" }
      architecture { operatingsystem.try(:architectures).try(:first) }
      medium { operatingsystem.try(:media).try(:first) }
      ptable { operatingsystem.try(:ptables).try(:first) }
      root_pass { '$1$rtd8Ub7R$5Ohzuy8WXlkaK9cA2T1wb0' }
      certname { name }

      factory :host_for_snapshots_ipv4_dhcp_el7 do
        operatingsystem { FactoryBot.build(:for_snapshots_centos_7_0) }
      end

      factory :host_for_snapshots_ipv4_dhcp_deb10 do
        operatingsystem { FactoryBot.build(:for_snapshots_debian_10) }
      end

      factory :host_for_snapshots_ipv4_dhcp_ubuntu18 do
        operatingsystem { FactoryBot.build(:for_snapshots_ubuntu_18) }
      end

      factory :host_for_snapshots_ipv4_dhcp_ubuntu20 do
        ptable { FactoryBot.build(:ptable, :ubuntu_autoinstall) }
        operatingsystem { FactoryBot.build(:for_snapshots_ubuntu_20) }
      end

      factory :host_for_snapshots_ipv4_dhcp_rhel9 do
        operatingsystem { FactoryBot.build(:for_snapshots_rhel9) }
      end
    end

    trait :with_dhcp_orchestration do
      managed
      compute_resource do
        taxonomies = {}
        # add taxonomy overrides in case it's set in the host object
        taxonomies[:locations] = [location] unless location.nil?
        taxonomies[:organizations] = [organization] unless organization.nil?
        FactoryBot.create(:libvirt_cr, taxonomies)
      end
      domain
      subnet do
        overrides = {
          :dhcp => FactoryBot.create(:dhcp_smart_proxy),
        }
        # add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?
        FactoryBot.create(
          :subnet_ipv4_with_bmc,
          overrides
        )
      end
      interfaces do
        [FactoryBot.build(:nic_primary_and_provision, :ip => subnet.network.sub(/0\Z/, '1'))]
      end
    end

    trait :with_dns_orchestration do
      managed
      compute_resource do
        taxonomies = {}
        # add taxonomy overrides in case it's set in the host object
        taxonomies[:locations] = [location] unless location.nil?
        taxonomies[:organizations] = [organization] unless organization.nil?
        FactoryBot.create(:libvirt_cr, taxonomies)
      end
      subnet do
        overrides = {:dns => FactoryBot.create(:dns_smart_proxy)}
        # add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?

        FactoryBot.create(:subnet_ipv4, overrides)
      end
      domain do
        FactoryBot.create(:domain,
          :dns => FactoryBot.create(:smart_proxy,
            :features => [FactoryBot.create(:feature, :dns)])
        )
      end
      interfaces do
        [FactoryBot.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryBot.build(:domain),
                                         :ip => subnet.network.sub(/0\Z/, '1'))]
      end
    end

    trait :with_ipv6_dns_orchestration do
      managed
      compute_resource do
        taxonomies = {}
        # add taxonomy overrides in case it's set in the host object
        taxonomies[:locations] = [location] unless location.nil?
        taxonomies[:organizations] = [organization] unless organization.nil?
        FactoryBot.create(:libvirt_cr, taxonomies)
      end
      subnet6 do
        overrides = {:dns => FactoryBot.create(:dns_smart_proxy)}
        # add taxonomy overrides in case it's set in the host object
        overrides[:locations] = [location] unless location.nil?
        overrides[:organizations] = [organization] unless organization.nil?

        FactoryBot.create(:subnet_ipv6, :dns, overrides)
      end
      domain do
        FactoryBot.create(:domain,
          :dns => FactoryBot.create(:smart_proxy,
            :features => [FactoryBot.create(:feature, :dns)])
        )
      end
      interfaces do
        [FactoryBot.build(:nic_managed, :without_ipv4,
          :primary => true,
          :provision => true,
          :domain => FactoryBot.build(:domain),
          :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    trait :with_dual_stack_dns_orchestration do
      with_dns_orchestration
      with_ipv6_dns_orchestration
      interfaces do
        [FactoryBot.build(:nic_managed,
          :primary => true,
          :provision => true,
          :domain => FactoryBot.build(:domain),
          :ip => subnet.network.sub(/0\Z/, '1'),
          :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    trait :with_tftp_subnet do
      subnet { FactoryBot.build(:subnet_ipv4, :tftp, locations: [location], organizations: [organization]) }
    end

    trait :with_tftp_and_dhcp_subnet do
      subnet { FactoryBot.build(:subnet_ipv4, :tftp, :dhcp, locations: [location], organizations: [organization]) }
    end

    trait :with_tftp_and_httpboot_subnet do
      subnet { FactoryBot.build(:subnet_ipv4, :tftp, :httpboot, locations: [location], organizations: [organization]) }
    end

    trait :with_templates_subnet do
      subnet { FactoryBot.build(:subnet_ipv4, :template, locations: [location], organizations: [organization]) }
    end

    trait :with_separate_provision_interface do
      interfaces do
        [FactoryBot.build(:nic_managed,
          :primary => true,
          :provision => false,
          :domain => FactoryBot.build(:domain)),
         FactoryBot.build(:nic_managed,
           :primary => false,
           :provision => true,
           :domain => FactoryBot.build(:domain),
           :subnet => FactoryBot.build(:subnet_ipv4, :tftp, locations: [location], organizations: [organization]))]
      end
    end

    trait :with_tftp_v6_subnet do
      subnet6 { FactoryBot.build(:subnet_ipv6, :tftp, locations: [location], organizations: [organization]) }
    end

    trait :with_tftp_orchestration do
      managed
      with_tftp_and_dhcp_subnet
      interfaces do
        [FactoryBot.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryBot.build(:domain),
                                         :subnet => subnet,
                                         :ip => subnet.network.sub(/0\Z/, '2'))]
      end
    end

    trait :with_tftp_orchestration_and_httpboot do
      managed
      with_tftp_and_httpboot_subnet
      interfaces do
        [FactoryBot.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryBot.build(:domain),
                                         :subnet => subnet,
                                         :ip => subnet.network.sub(/0\Z/, '2'))]
      end
    end

    trait :with_tftp_v6_orchestration do
      managed
      with_tftp_v6_subnet
      interfaces do
        [FactoryBot.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryBot.build(:domain),
                                         :subnet6 => subnet6,
                                         :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    trait :with_tftp_dual_stack_orchestration do
      managed
      with_tftp_subnet
      with_tftp_v6_subnet
      interfaces do
        [FactoryBot.build(:nic_managed, :primary => true,
                                         :provision => true,
                                         :domain => FactoryBot.build(:domain),
                                         :subnet => subnet,
                                         :subnet6 => subnet6,
                                         :ip => subnet.network.sub(/0\Z/, '2'),
                                         :ip6 => IPAddr.new(subnet6.ipaddr.to_i + 1, subnet6.family).to_s)]
      end
    end

    trait :with_realm do
      realm
    end

    trait :without_owner do
      owner { nil }
    end

    trait :with_registration_facet do
      association :registration_facet, factory: :registration_facet, strategy: :build
    end

    trait :with_infrastructure_facet do
      association :infrastructure_facet, factory: :infrastructure_facet, strategy: :build
    end
  end

  factory :hostgroup do
    sequence(:name) { |n| "hostgroup#{n}" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :with_parent do
      association :parent, :factory => :hostgroup
    end

    trait :with_compute_resource do
      compute_resource { FactoryBot.create(:compute_resource, :libvirt) }
    end

    trait :with_config_group do
      config_groups { [FactoryBot.create(:config_group)] }
    end

    trait :with_parameter do
      after(:create) do |hg, evaluator|
        FactoryBot.create(:hostgroup_parameter, :hostgroup => hg)
        hg.group_parameters.reload
      end
    end

    trait :with_subnet do
      association :subnet, :factory => :subnet_ipv4
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

    trait :with_domain do
      domain
    end

    trait :with_puppet_ca do
      puppet_ca_proxy do
        FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, :puppetca)])
      end
    end

    trait :with_orchestration do
      architecture
      ptable
      operatingsystem do
        FactoryBot.create(:operatingsystem, :architectures => [architecture], :ptables => [ptable])
      end
    end
  end
end
