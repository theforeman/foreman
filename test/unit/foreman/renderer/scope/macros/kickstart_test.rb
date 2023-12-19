require 'test_helper'

class KickstartTest < ActiveSupport::TestCase
  setup do
    os = FactoryBot.create(:for_snapshots_rhel9, :with_provision, :with_associations)

    @host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => os,
      :interfaces => [
        FactoryBot.build(:nic_managed, :primary => true),
        FactoryBot.build(:nic_managed, :provision => true),
      ])

    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::Kickstart
    end.send(:new, host: @host, source: source)
    # HostInfo.stubs(:providers).returns([HostDummyEncInfo])
  end

  describe '#network' do
    test 'should return a network line for an interface' do
      actual = @scope.kickstart_network(
        @host.managed_interfaces.first,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/network/, actual)
    end

    test 'should skip non-managed interfaces' do
      iface = FactoryBot.build(:nic_base, :primary => true)

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_nil actual
    end

    test 'should create bond interface' do
      iface = FactoryBot.build(
        :nic_bond,
        primary: true,
        identifier: 'test_bond',
        attached_devices: ['bonded_slave1', 'bonded_slave2'],
        mode: 'test_mode',
        bond_options: 'option_a=foo option_b=bar'
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/bondslaves/, actual)
      assert_match(/bonded_slave1/, actual)
      assert_match(/bonded_slave2/, actual)
      assert_match(/mode=test_mode,/, actual)
      assert_match(/,option_a=foo,option_b=bar/, actual)
    end

    test 'should set correct noipv6 flag' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4)
      )

      iface.subnet6 = nil

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--noipv6/, actual)
    end

    test 'should set correct noipv4 flag' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet6: FactoryBot.build(:subnet_ipv6)
      )

      iface.subnet = nil

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--noipv4/, actual)
    end

    test 'should use static ipv4 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4_static_for_snapshots)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: true,
        static6: false
      )

      assert_match(/--ip/, actual)
      assert_match(/--netmask/, actual)
      assert_match(/--gateway/, actual)
      assert_match(/--bootproto/, actual)
      assert_match(/static/, actual)
    end

    test 'should use dhcp ipv4 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4_with_domains)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--bootproto/, actual)
      assert_match(/dhcp/, actual)
    end

    test 'should use static ipv6 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet6: FactoryBot.build(:subnet_ipv6_static_for_snapshots)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: true
      )

      assert_match(/--ipv6=/, actual)
      assert_match(/--ipv6gateway=/, actual)
    end

    test 'should use dhcp ipv6 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet6: FactoryBot.build(:subnet_ipv6_with_domains)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--ipv6/, actual)
      assert_match(/dhcp/, actual)
    end

    test 'should use auto ipv6 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet6: FactoryBot.build(:subnet_ipv6_dhcp_for_snapshots)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: true,
        static: false,
        static6: false
      )

      assert_match(/--ipv6/, actual)
      assert_match(/auto/, actual)
    end

    test 'should set vlan options' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        virtual: true,
        tag: '333',
        attached_to: 'test_iface1'
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--vlanid/, actual)
      assert_match(/333/, actual)
      assert_match(/--interfacename/, actual)
    end

    test 'should set DNS servers' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4_static_for_snapshots)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--nameserver/, actual)
      assert_match(/192.168.42.2/, actual)
      assert_match(/192.168.42.3/, actual)
    end

    test 'should set nodns flag' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4)
      )

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 9,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--nodns/, actual)
    end

    test 'should set search domain' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4)
      )

      iface.domain = FactoryBot.build(:domain, name: 'test.com')

      actual = @scope.kickstart_network(
        iface,
        host: @host,
        rhel_compatible: true,
        os_major: 10,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--ipv4-dns-search/, actual)
      assert_match(/test.com/, actual)
    end
  end
end
