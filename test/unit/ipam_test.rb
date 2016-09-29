require 'test_helper'

class IPAMTest < ActiveSupport::TestCase
  context 'dhcp' do
    test "should find unused IP on proxy if proxy is set" do
      subnet = FactoryGirl.build(:subnet_ipv4, :ipam_dhcp, :name => 'my_subnet', :network => '192.168.1.0')
      subnet.stubs(:dhcp? => true)
      subnet.stubs(:dhcp => mock('attribute', :url => 'proxy.example.com'))
      fake_proxy = mock("dhcp_proxy")
      fake_proxy.stubs(:unused_ip => {'ip' => '192.168.1.25'})
      subnet.stubs(:dhcp_proxy => fake_proxy)
      ipam = IPAM::Dhcp.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_equal '192.168.1.25', ipam.suggest_ip
    end
  end

  context 'internal db' do
    test "should find unused IPv4 in internal DB" do
      subnet = FactoryGirl.create(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.2.0',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet, :excluded_ips => ['192.168.2.1', '192.168.2.2'])
      assert_equal '192.168.2.3', ipam.suggest_ip
    end

    test "should find unused IPv6 in internal DB" do
      subnet = FactoryGirl.create(
        :subnet_ipv6, :name => 'my_subnet',
        :network => '2001:db8::',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet)
      assert_equal '2001:db8::1', ipam.suggest_ip
    end

    test "should respect subnet from and to if it's set" do
      subnet = FactoryGirl.create(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.2.0',
        :from => '192.168.2.10',
        :to => '192.168.2.12',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet)
      assert_equal '192.168.2.10', ipam.suggest_ip
    end
  end

  context 'EUI-64 IPAM' do
    test "should calculate unused IP via eui-64" do
      subnet = FactoryGirl.build(:subnet_ipv6,
                                 :network => '2001:db8::',
                                 :mask => 'ffff:ffff:ffff:ffff::',
                                 :ipam => IPAM::MODES[:eui64])
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_equal '2001:db8::211:22ff:fe33:4455', ipam.suggest_ip
    end

    test 'should not suggest an ip if given mac is invalid' do
      subnet = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::')
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => 'invalid')
      assert_nil ipam.suggest_ip
      refute_empty ipam.errors
      assert_includes ipam.errors.full_messages, 'Mac is not a valid MAC address'
    end

    test 'should not suggest an ip if prefix length is not suitable' do
      subnet = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::', :cidr => 70)
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_nil ipam.suggest_ip
      refute_empty ipam.errors
      assert_includes ipam.errors.full_messages, 'Subnet Prefix length must be /64 or less to use EUI-64'
    end
  end
end
