require 'test_helper'

class IPAMTest < ActiveSupport::TestCase
  context 'dhcp' do
    test "should find unused IP on proxy if proxy is set" do
      subnet = FactoryBot.build_stubbed(:subnet_ipv4, :ipam_dhcp, :name => 'my_subnet', :network => '192.168.1.0')
      subnet.stubs(:dhcp? => true)
      subnet.stubs(:dhcp => mock('attribute', :url => 'proxy.example.com'))
      fake_proxy = mock("dhcp_proxy")
      fake_proxy.stubs(:unused_ip => {'ip' => '192.168.1.25'})
      subnet.stubs(:dhcp_proxy => fake_proxy)
      ipam = IPAM::DHCP.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_equal '192.168.1.25', ipam.suggest_ip
    end
  end

  context 'internal db' do
    test "should find unused IPv4" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.2.0',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet, :excluded_ips => ['192.168.2.1', '192.168.2.2'])
      assert_equal '192.168.2.3', ipam.suggest_ip
    end

    test "should find unused IPv6" do
      subnet = FactoryBot.build(
        :subnet_ipv6, :name => 'my_subnet',
        :network => '2001:db8::',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet)
      assert_equal '2001:db8::1', ipam.suggest_ip
    end

    test "should respect subnet from and to if it's set" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.2.0',
        :from => '192.168.2.10',
        :to => '192.168.2.12',
        :ipam => IPAM::MODES[:db])
      ipam = IPAM::Db.new(:subnet => subnet)
      assert_equal '192.168.2.10', ipam.suggest_ip
    end
  end

  context 'random db' do
    test "should find unused IPv4" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '10.0.0.0',
        :mask => '255.0.0.0',
        :ipam => IPAM::MODES[:random_db])
      ipam = IPAM::RandomDb.new(:subnet => subnet)
      assert_match /^10\./, ipam.suggest_ip
    end

    test "should return IPv4 based on MAC if provided and ip blocking is turned off" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '10.0.0.0',
        :mask => '255.0.0.0',
        :ipam => IPAM::MODES[:random_db])
      ipam1 = IPAM::RandomDb.new(:subnet => subnet, :mac => "AA:BB:CC:DD:EE:11", :block_ip_minutes => 0)
      ipam2 = IPAM::RandomDb.new(:subnet => subnet, :mac => "AA:BB:CC:DD:EE:11", :block_ip_minutes => 0)
      assert_equal ipam1.suggest_ip, ipam2.suggest_ip
    end

    test "should return IPv4 based on MAC if provided and ip blocking is on" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '10.0.0.0',
        :mask => '255.0.0.0',
        :ipam => IPAM::MODES[:random_db])
      ipam1 = IPAM::RandomDb.new(:subnet => subnet, :mac => "AA:BB:CC:DD:EE:22")
      ipam2 = IPAM::RandomDb.new(:subnet => subnet, :mac => "AA:BB:CC:DD:EE:22")
      assert_not_empty ipam1.suggest_ip
      assert_not_empty ipam2.suggest_ip
      assert_not_equal ipam1.suggest_ip, ipam2.suggest_ip
    end

    test "should find the only possible IPv4" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.11.0',
        :from => '192.168.11.5',
        :to => '192.168.11.5',
        :ipam => IPAM::MODES[:random_db])
      ipam = IPAM::RandomDb.new(:subnet => subnet)
      assert_equal '192.168.11.5', ipam.suggest_ip
    end

    test "should find the only possible IPv4 with excluded IPs" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '192.168.11.0',
        :from => '192.168.11.5',
        :to => '192.168.11.100',
        :ipam => IPAM::MODES[:random_db])
      ipam = IPAM::RandomDb.new(:subnet => subnet, :excluded_ips => (1..99).map { |x| "192.168.11.#{x}" })
      assert_equal '192.168.11.100', ipam.suggest_ip
    end

    test "should stop trying to find random IPv4 after reasonable time" do
      subnet = FactoryBot.build(
        :subnet_ipv4, :name => 'my_subnet',
        :network => '10.0.0.0',
        :mask => '255.0.0.0',
        :ipam => IPAM::MODES[:random_db])
      ipam = IPAM::RandomDb.new(:subnet => subnet)
      ipam.excluded_ips.stubs(:include?).returns(true)
      assert_nil ipam.suggest_ip
    end

    context 'subnet_range inclusion' do
      test 'should return true for big ipv6 subnet' do
        subnet = FactoryBot.build(
          :subnet_ipv6, :name => 'my_subnet',
          :network => '2001:db8::',
          :mask => 'ffff:ffff:ffff:ffff::',
          :ipam => IPAM::MODES[:random_db])

        ipam = IPAM::RandomDb.new(:subnet => subnet)

        assert_equal true, ipam.ip_include?('2001:db8::1')
      end

      test 'should return false for big ipv6 subnet' do
        subnet = FactoryBot.build(
          :subnet_ipv6, :name => 'my_subnet',
          :network => '2001:db8::',
          :mask => 'ffff:ffff:ffff:ffff::',
          :ipam => IPAM::MODES[:random_db])
        ipam = IPAM::RandomDb.new(:subnet => subnet)

        assert_equal false, ipam.ip_include?('2001:db7::1')
      end

      test 'should return true for ipv4 subnet' do
        subnet = FactoryBot.build(
          :subnet_ipv4, :name => 'my_subnet',
          :network => '10.0.0.1',
          :mask => '255.255.255.0',
          :ipam => IPAM::MODES[:random_db])
        ipam = IPAM::RandomDb.new(:subnet => subnet)

        assert_equal true, ipam.ip_include?('10.0.0.100')
      end

      test 'should return false for ipv4 subnet' do
        subnet = FactoryBot.build(
          :subnet_ipv4, :name => 'my_subnet',
          :network => '10.0.0.1',
          :mask => '255.255.255.0',
          :ipam => IPAM::MODES[:random_db])
        ipam = IPAM::RandomDb.new(:subnet => subnet)

        assert_equal false, ipam.ip_include?('192.168.0.50')
      end
    end
  end

  context 'EUI-64 IPAM' do
    test "should calculate unused IP via eui-64" do
      subnet = FactoryBot.build_stubbed(:subnet_ipv6,
        :network => '2001:db8::',
        :mask => 'ffff:ffff:ffff:ffff::',
        :ipam => IPAM::MODES[:eui64])
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_equal '2001:db8::211:22ff:fe33:4455', ipam.suggest_ip
    end

    test 'should not suggest an ip if given mac is invalid' do
      subnet = FactoryBot.build_stubbed(:subnet_ipv6, :network => '2001:db8::')
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => 'invalid')
      assert_nil ipam.suggest_ip
      refute_empty ipam.errors
      assert_includes ipam.errors.full_messages, 'Mac is not a valid MAC address'
    end

    test 'should not suggest an ip if prefix length is not suitable' do
      subnet = FactoryBot.build_stubbed(:subnet_ipv6, :network => '2001:db8::', :cidr => 70)
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      assert_nil ipam.suggest_ip
      refute_empty ipam.errors
      assert_includes ipam.errors.full_messages, 'Subnet Prefix length must be /64 or less to use EUI-64'
    end
  end
end
