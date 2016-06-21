require 'test_helper'

class IPAMTest < ActiveSupport::TestCase
  test 'should raise an exception if given mac is invalid' do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::')
    exception = assert_raise Foreman::Exception do
      IPAM::Eui64.new(:subnet => s, :mac => 'invalid')
    end
    assert_includes exception.message, 'not a valid MAC address'
  end

  test 'should have a ipam range when from and to are set' do
    subnet = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12', :ipam => IPAM::MODES[:db])
    ipam = IPAM::Db.new(:subnet => subnet)
    assert_equal '192.168.2.10..192.168.2.12', ipam.range.to_s
  end

  test 'should have a default ipam range' do
    subnet = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :ipam => IPAM::MODES[:db])
    ipam = IPAM::Db.new(:subnet => subnet)
    assert_equal '192.168.2.1..192.168.2.254', ipam.range.to_s
  end

  test 'should list used ips' do
    subnet = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :dns_primary => '192.168.2.10', :gateway => '192.168.2.3', :ipam => IPAM::MODES[:db])

    ipam = IPAM::Db.new(:subnet => subnet)

    assert_includes ipam.used_ips, '192.168.2.10'
    refute_includes ipam.used_ips, '192.168.2.3'
  end

  test 'should return usage' do
    subnet = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :dns_primary => '192.168.2.10', :gateway => '192.168.2.3', :ipam => IPAM::MODES[:db])

    ipam = IPAM::Db.new(:subnet => subnet)
    assert_equal 1, ipam.usage
  end

  context 'dhcp' do
    setup do
      @subnet = FactoryGirl.build(:subnet_ipv4, :ipam_dhcp, :name => 'my_subnet', :network => '192.168.1.0')
      @subnet.stubs(:dhcp? => true)
      @subnet.stubs(:dhcp => mock('attribute', :url => 'proxy.example.com'))
      fake_proxy = mock("dhcp_proxy")
      fake_proxy.stubs(:unused_ip => {'ip' => '192.168.1.25'})
      fake_proxy.stubs(:subnet_usage => {"free" => 246, "size" => 254, "used" => 8})
      @subnet.stubs(:dhcp_proxy => fake_proxy)
    end

    test "should find unused IP on proxy if proxy is set" do
      ipam = IPAM::Dhcp.new(:subnet => @subnet, :mac => '00:11:22:33:44:55')
      assert_equal '192.168.1.25', ipam.suggest_ip
    end

    test 'should return usage' do
      ipam = IPAM::Dhcp.new(:subnet => @subnet)
      assert_equal 8, ipam.usage
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

    test 'should raise an exception if prefix length is not suitable' do
      subnet = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::', :cidr => 70)
      ipam = IPAM::Eui64.new(:subnet => subnet, :mac => '00:11:22:33:44:55')
      exception = assert_raise Foreman::Exception do
        ipam.suggest_ip
      end
      assert_includes exception.message, 'Prefix length must be /64 or less'
    end
  end
end
