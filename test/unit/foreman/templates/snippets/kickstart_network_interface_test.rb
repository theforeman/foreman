require 'test_helper'

class KickstartNetworkInterfaceTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(iface, host:, use_slaac:, static:, static6:)
    @snippet ||= File.read(File.expand_path('../../../../../app/views/unattended/provisioning_templates/snippet/kickstart_network_interface.erb', __dir__))

    source = OpenStruct.new(
      name: 'Test',
      content: @snippet
    )

    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: host,
      source: source,
      variables: {
        iface: iface,
        host: host,
        use_slaac: use_slaac,
        static: static,
        static6: static6,
      })

    renderer.render(source, scope)
  end

  setup do
    os = FactoryBot.create(:for_snapshots_rhel9, :with_provision, :with_associations)

    @host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => os,
      :interfaces => [
        FactoryBot.build(:nic_managed, :primary => true),
        FactoryBot.build(:nic_managed, :provision => true),
      ])
  end

  describe '#network' do
    test 'should return a network line for an interface' do
      actual = render_template(
        @host.managed_interfaces.first,
        host: @host,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/network/, actual)
    end

    test 'should skip non-managed interfaces' do
      iface = FactoryBot.build(:nic_base, :primary => true)

      require 'pry-byebug'
      binding.pry

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
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

      actual = render_template(
        iface,
        host: @host,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--nodns/, actual)
    end

    test 'should set search domain' do
      os = FactoryBot.create(
        :for_snapshots_rhel9,
        :with_provision,
        :with_associations,
        name:  'RHEL',
        major:  '10',
        minor:  '0',
        type:  'Redhat',
        title:  'Red Hat Enterprise Linux 10.0'
      )

      @host.operatingsystem = os

      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet: FactoryBot.build(:subnet_ipv4)
      )

      iface.domain = FactoryBot.build(:domain, name: 'test.com')

      actual = render_template(
        iface,
        host: @host,
        use_slaac: false,
        static: false,
        static6: false
      )

      assert_match(/--ipv4-dns-search/, actual)
      assert_match(/test.com/, actual)
    end
  end
end
