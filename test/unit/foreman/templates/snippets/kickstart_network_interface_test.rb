require 'test_helper'

class KickstartNetworkInterfaceTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(iface, host:, static:, static6:)
    @snippet ||= File.read(Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'kickstart_network_interface.erb'))

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
        static: false,
        static6: false
      )

      assert_match(/network/, actual)
    end

    test 'should skip non-managed interfaces' do
      iface = FactoryBot.build(:nic_base, primary: true, managed: false)

      actual = render_template(
        iface,
        host: @host,
        static: false,
        static6: false
      )

      assert_empty actual
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
        static: false,
        static6: false
      )

      assert_not_nil(bondslaves_match = /--bondslaves=([^ ]*)/.match(actual))
      assert_match(/bonded_slave1/, bondslaves_match[1])
      assert_match(/bonded_slave2/, bondslaves_match[1])
      assert_not_nil(bondopts_match = /--bondopts=([^ ]*)/.match(actual))
      assert_match(/mode=test_mode,/, bondopts_match[1])
      assert_match(/,option_a=foo,option_b=bar/, bondopts_match[1])
    end

    test 'should create bridge interface' do
      iface = FactoryBot.build(
        :nic_bridge,
        primary: true,
        identifier: 'test_bridge',
        attached_devices: ['bridged_slave1', 'bridged_slave2'],
        attrs: {bridge: true}
      )

      actual = render_template(
        iface,
        host: @host,
        static: false,
        static6: false
      )

      assert_not_nil(bridgeslaves_match = /--bridgeslaves=([^ ]*)/.match(actual))
      assert_match(/bridged_slave1/, bridgeslaves_match[1])
      assert_match(/bridged_slave2/, bridgeslaves_match[1])
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
        static: true,
        static6: false
      )

      assert_match(/--ip/, actual)
      assert_match(/--netmask/, actual)
      assert_match(/--gateway/, actual)
      assert_not_nil(bootproto_match = /--bootproto ([^ ]*)/.match(actual))
      assert_match(/static/, bootproto_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(bootproto_match = /--bootproto ([^ ]*)/.match(actual))
      assert_match(/dhcp/, bootproto_match[1])
    end

    test 'should use static ipv6 configuration' do
      iface = FactoryBot.build(
        :nic_managed,
        primary: true,
        subnet6: FactoryBot.build(:subnet_ipv6_static_for_snapshots),
        ip6: '2001:db8:42::2'
      )

      actual = render_template(
        iface,
        host: @host,
        static: false,
        static6: true
      )

      assert_not_nil(ipv6_match = %r{--ipv6=([^/]*)/([^ ]*)}.match(actual))
      assert_match(iface.ip6, ipv6_match[1])
      assert_match(iface.subnet6.cidr.to_s, ipv6_match[2])
      assert_not_nil(gateway_match = /--ipv6gateway=([^ ]*)/.match(actual))
      assert_match(iface.subnet6.gateway, gateway_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(ipv6_match = /--ipv6 ([^ ]*)/.match(actual))
      assert_match(/auto/, ipv6_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(ipv6_match = /--ipv6 ([^ ]*)/.match(actual))
      assert_match(/auto/, ipv6_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(vlan_match = /--vlanid=([^ ]*)/.match(actual))
      assert_match(/333/, vlan_match[1])
      assert_not_nil(interfacename_match = /--interfacename=([^ ]*)/.match(actual))
      assert_match(/vlan333/, interfacename_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(nameserver_match = /--nameserver=([^ ]*)/.match(actual))
      # order is not promised for nameserver list
      assert_match(/192.168.42.2/, nameserver_match[1])
      assert_match(/192.168.42.3/, nameserver_match[1])
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
        static: false,
        static6: false
      )

      assert_not_nil(dns_search_match = /--ipv4-dns-search=([^ ]*)/.match(actual))
      assert_match(/test.com/, dns_search_match[1])
    end
  end
end
