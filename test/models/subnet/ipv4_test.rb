require 'test_helper'

class Subnet::Ipv4Test < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    @subnet = Subnet::Ipv4.new
  end

  should_not allow_value('255.0.0.255').for(:mask)
  should_not allow_value('255.255.255.1111').for(:mask)
  should_not allow_value('1234.101.102.103').for(:network)
  should_not allow_value('100101.102.103.').for(:network)
  should_not allow_value('300.300.300.0').for(:network)
  should_not allow_value('100.101.102').for(:network)
  should_not allow_value(67).for(:mtu)
  should_not allow_value(65537).for(:mtu)
  should allow_value('100.101.102.103.').for(:network) # clean invalid addresses
  should allow_value('100.101.102.25555').for(:network) # clean invalid addresses
  # Test smart proxies from Subnet are inherited
  should belong_to(:tftp)
  should belong_to(:dns)
  should belong_to(:dhcp)

  test 'can be created with domains' do
    subnet = FactoryBot.build(:subnet_ipv4)
    subnet.domain_ids = [domains(:mydomain).id]
    assert subnet.save
  end

  test "cidr setter should set the mask" do
    @subnet = FactoryBot.build_stubbed(:subnet_ipv4)
    @subnet.cidr = 24
    assert_equal '255.255.255.0', @subnet.mask
  end

  test "cidr setter should not raise exception for invalid value" do
    @subnet = FactoryBot.build_stubbed(:subnet_ipv4)
    @subnet.cidr = 'green'
  end

  test "should find the subnet by ip" do
    @subnet = Subnet::Ipv4.new(:network => "123.123.123.0", :mask => "255.255.255.0", :name => "valid")
    assert @subnet.save
    assert @subnet.domain_ids = [domains(:mydomain).id]
    assert_equal @subnet, Subnet::Ipv4.subnet_for("123.123.123.1")
  end

  test "should find the subnet with highest CIDR prefix (24) by IP" do
    Subnet::Ipv4.create!(:network => "128.150.0.0", :mask => "255.255.0.0", :name => "net_16")
    to_find = Subnet::Ipv4.create!(:network => "128.150.143.0", :mask => "255.255.255.0", :name => "net_24")
    assert_equal to_find, Subnet::Ipv4.subnet_for("128.150.143.31")
  end

  test "should find the subnet with highest CIDR prefix (30) by IP" do
    to_find = Subnet::Ipv4.create!(:network => "128.150.143.128", :mask => "255.255.255.252", :name => "net_30")
    Subnet::Ipv4.create!(:network => "128.150.0.0", :mask => "255.255.0.0", :name => "net_16")
    assert_equal to_find, Subnet::Ipv4.subnet_for("128.150.143.129")
  end

  test "from cant be bigger than to range" do
    s      = subnets(:one)
    s.to   = "2.3.4.15"
    s.from = "2.3.4.17"
    assert !s.save
  end

  test "should be able to save ranges" do
    s = subnets(:one)
    s.from = "2.3.4.15"
    s.to   = "2.3.4.17"
    assert s.save
  end

  test "should not be able to save ranges if they dont belong to the subnet" do
    s = subnets(:one)
    s.from = "2.3.3.15"
    s.to   = "2.3.4.17"
    assert !s.save
  end

  test "should not be able to save ranges if one of them is missing" do
    s = subnets(:one)
    s.from = "2.3.4.15"
    assert !s.save
    s.to = "2.3.4.17"
    assert s.save
  end

  test "should not be able to save ranges if one of them is invalid" do
    s = subnets(:one)
    s.from = "2.3.4.abc"
    s.to   = "2.3.4.17"
    refute s.valid?
  end

  test "should fix typo with extra dots to single dot" do
    s = subnets(:one)
    s.network = "10..0.0..22"
    assert s.save
    assert_equal "10.0.0.22", s.network
  end

  test "should fix typo with extra 5 after 255" do
    s = subnets(:one)
    s.mask = "2555.255.25555.0"
    assert s.save
    assert_equal "255.255.255.0", s.mask
  end

  test "#unused_ip should suggest IP" do
    ipam = mock()
    ipam.expects(:suggest_ip).returns('1.1.1.1')
    IPAM.expects(:new).once.returns(ipam)
    subnet = FactoryBot.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12', :ipam => IPAM::MODES[:db])
    assert_equal '1.1.1.1', subnet.unused_ip.suggest_ip
  end

  test "#unused_ip does not suggest IP if mode is set to none" do
    subnet = FactoryBot.build_stubbed(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12')
    subnet.stubs(:dhcp? => false, :ipam => IPAM::MODES[:none])
    assert_nil subnet.unused_ip.suggest_ip
  end

  test "#known_ips includes all host and interfaces IPs assigned to this subnet" do
    subnet = FactoryBot.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :dns_primary => '192.168.2.2', :gateway => '192.168.2.3', :ipam => IPAM::MODES[:db])
    host = FactoryBot.create(:host, :subnet => subnet, :ip => '192.168.2.1')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet => subnet, :name => "", :ip => '192.168.2.4'

    assert_includes subnet.known_ips, '192.168.2.1'
    assert_includes subnet.known_ips, '192.168.2.2'
    assert_includes subnet.known_ips, '192.168.2.3'
    assert_includes subnet.known_ips, '192.168.2.4'
    assert_equal 4, subnet.known_ips.size
  end

  test "#known_ips returns host/interface IPs after creation" do
    subnet = FactoryBot.create(:subnet_ipv4, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :dns_primary => '192.168.2.2', :gateway => '192.168.2.3', :ipam => IPAM::MODES[:db])
    refute_includes subnet.known_ips, '192.168.2.10'
    refute_includes subnet.known_ips, '192.168.2.11'

    host = FactoryBot.create(:host, :subnet => subnet, :ip => '192.168.2.10')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet => subnet, :name => "", :ip => '192.168.2.11'

    assert_includes subnet.known_ips, '192.168.2.10'
    assert_includes subnet.known_ips, '192.168.2.11'
  end

  context 'import subnets' do
    setup do
      @mock_proxy = mock('dhcp_proxy')
      @mock_proxy.stubs(:has_feature? => true)
      @mock_proxy.stubs(:url => 'http://fake')
    end

    test 'options are imported from the dhcp proxy' do
      dhcp_options = { 'routers' => ['192.168.11.1'],
                       'domain_name_servers' => ['192.168.11.1', '8.8.8.8'],
                       'range' => ['192.168.11.0', '192.168.11.200'] }
      ProxyAPI::DHCP.any_instance.
        stubs(:subnets => [{ 'network' => '192.168.11.0',
                              'netmask' => '255.255.255.0',
                              'options' => dhcp_options }])
      Subnet.expects(:new).with(:network => "192.168.11.0",
                                :mask => "255.255.255.0",
                                :gateway => "192.168.11.1",
                                :dns_primary => "192.168.11.1",
                                :dns_secondary => "8.8.8.8",
                                :from => "192.168.11.0",
                                :to => "192.168.11.200",
                                :dhcp => @mock_proxy)
      Subnet::Ipv4.import(@mock_proxy)
    end

    test 'imports subnets without options' do
      ProxyAPI::DHCP.any_instance.
        stubs(:subnets => [{ 'network' => '192.168.11.0',
                              'netmask' => '255.255.255.0' }])
      Subnet.expects(:new).with(:network => "192.168.11.0",
                                :mask => "255.255.255.0",
                                :dhcp => @mock_proxy)
      Subnet::Ipv4.import(@mock_proxy)
    end
  end

  test "should not assign proxies without adequate features" do
    proxy = smart_proxies(:puppetmaster)
    subnet = Subnet::Ipv4.new(:name => "test subnet",
                        :network => "192.168.100.0",
                        :mask => "255.255.255.0",
                        :dhcp_id => proxy.id,
                        :dns_id => proxy.id,
                        :tftp_id => proxy.id)
    refute subnet.save
    assert_equal "does not have the DNS feature", subnet.errors["dns_id"].first
    assert_equal "does not have the DHCP feature", subnet.errors["dhcp_id"].first
    assert_equal "does not have the TFTP feature", subnet.errors["tftp_id"].first
  end

  test "#type cannot be updated for existing subnet" do
    subnet = subnets(:one)
    subnet.type = 'Subnet::Ipv6'
    refute subnet.save
    assert subnet.errors[:type].include?("can't be updated after subnet is saved")
  end

  test "should inherit model name from parent class" do
    assert_equal Subnet.model_name, Subnet::Ipv4.model_name
  end
end
