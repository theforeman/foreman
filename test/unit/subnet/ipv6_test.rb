require 'test_helper'

class SubnetIpv6Test < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"
  end

  test "should have a network" do
    @subnet = FactoryGirl.build(:subnet_ipv6)
    old_network = @subnet.network
    @subnet.network = nil
    refute @subnet.valid?

    @subnet.network = old_network
    assert @subnet.valid?
  end

  test "should have a mask" do
    @subnet = FactoryGirl.build(:subnet_ipv6)
    old_mask = @subnet.mask
    @subnet.mask = nil
    refute @subnet.valid?

    @subnet.mask = old_mask
    assert @subnet.valid?
  end

  test "cidr setter should set the mask" do
    @subnet = FactoryGirl.build(:subnet_ipv6)
    @subnet.cidr = 64
    assert_equal 'ffff:ffff:ffff:ffff::', @subnet.mask
  end

  test "network should have ip format" do
    @subnet = FactoryGirl.build(:subnet_ipv6, :network => "asf:fwe6::we6s:q1")
    refute @subnet.valid?
  end

  test "mask should have ip format" do
    @subnet = FactoryGirl.build(:subnet_ipv6, :mask => "asf:fwe6::we6s:q1")
    refute @subnet.valid?
  end

  test "network should be unique" do
    first = FactoryGirl.create(:subnet_ipv6)
    subnet = FactoryGirl.build(:subnet_ipv6, :network => first.network)
    refute subnet.valid?
  end

  test "network should be unique, after normalization" do
    FactoryGirl.create(:subnet_ipv6, :network => '2001:db8::')
    subnet = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8:0000::')
    refute subnet.valid?
  end

  test "the name should be unique in the domain scope" do
    first = FactoryGirl.create(:subnet_ipv6, :with_domains)
    subnet = FactoryGirl.build(:subnet_ipv6, :name => first.name, :domains => first.domains)
    refute subnet.valid?
  end

  test "when to_label is applied should show the domain, the mask and network" do
    subnet = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::', :name => 'subnet')
    assert_equal "subnet (2001:db8::/64)", subnet.to_label
  end

  test "should find the subnet by ip" do
    subnet = FactoryGirl.create(:subnet_ipv6)
    assert_equal subnet, Subnet::Ipv6.subnet_for(get_ip(subnet, 10))
  end

  test "from cant be bigger than to range" do
    s = FactoryGirl.build(:subnet_ipv6)
    s.to = get_ip(s, 10)
    s.from = get_ip(s, 17)
    refute s.valid?
  end

  test "should be able to save ranges" do
    s = FactoryGirl.build(:subnet_ipv6)
    s.from = get_ip(s, 10)
    s.to = get_ip(s, 17)
    assert s.save
  end

  test "should not be able to save ranges if they dont belong to the subnet" do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8:1::')
    s.from = '2001:db8:2::1'
    s.to = '2001:db8:2::2'
    refute s.valid?
  end

  test "should not be able to save ranges if one of them is missing" do
    s = FactoryGirl.build(:subnet_ipv6)
    s.from = get_ip(s, 10)
    refute s.valid?
    s.to = get_ip(s, 17)
    assert s.valid?
  end

  test "should not be able to save ranges if one of them is invalid" do
    s = FactoryGirl.build(:subnet_ipv6)
    s.from = get_ip(s, 10).gsub(/:[^:]*:/, ':xyz:')
    s.to = get_ip(s, 17)
    refute s.valid?
  end

  test "should strip whitespace before save" do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::')
    s.network = " #{s.network}   "
    s.mask = " #{s.mask}   "
    s.gateway = " 2001:db8::1   "
    s.dns_primary = " 2001:db8::2   "
    s.dns_secondary = " 2001:db8::3   "
    assert s.save
    assert_equal '2001:db8::', s.network
    assert_equal 'ffff:ffff:ffff:ffff::', s.mask
    assert_equal '2001:db8::1', s.gateway
    assert_equal '2001:db8::2', s.dns_primary
    assert_equal '2001:db8::3', s.dns_secondary
  end

  test "should not allow an address greater than 45 characters" do
    s = FactoryGirl.build(:subnet_ipv6, :mask => 9.times.map { 'abcd' }.join(':'))
    refute s.valid?
    assert_match /is invalid/, s.errors.full_messages.join("\n")
  end

  test "trailing colons in addresses are invalid" do
    refute FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::1:').valid?
  end

  test "more than 4 chars in a block is invalid" do
    refute FactoryGirl.build(:subnet_ipv6, :network => '2001:db8:abcde::1').valid?
  end

  # test module StripWhitespace which strips leading and trailing whitespace on :name field
  test "should strip whitespace on name" do
    s = FactoryGirl.build(:subnet_ipv6, :name => '    ABC Network     ')
    assert s.save!
    assert_equal "ABC Network", s.name
  end

  test "#mac_to_ip should convert mac to ip in subnet" do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::')
    ip = s.mac_to_ip('00:11:22:33:44:55')
    assert_equal '2001:db8::211:22ff:fe33:4455', ip
  end

  test "#mac_to_ip should raise an exception if prefix length is not suitable" do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::', :cidr => 70)
    assert_raise Foreman::Exception do
      s.mac_to_ip('00:11:22:33:44:55')
    end
  end

  test "#mac_to_ip should raise an exception if given mac is invalid" do
    s = FactoryGirl.build(:subnet_ipv6, :network => '2001:db8::')
    assert_raise Foreman::Exception do
      s.mac_to_ip('HANS')
    end
  end

  test "should calculate unused IP via eui-64" do
    subnet = FactoryGirl.build(:subnet_ipv6,
                                :network => '2001:db8::',
                                :mask => 'ffff:ffff:ffff:ffff::',
                                :ipam => Subnet::IPAM_MODES[:eui64])
    assert_equal '2001:db8::211:22ff:fe33:4455', subnet.unused_ip('00:11:22:33:44:55')
  end

  test "should find unused IP in internal DB" do
    host = FactoryGirl.create(:host)
    subnet = FactoryGirl.create(:subnet_ipv6,
                                :name => 'my_subnet',
                                :network => '2001:db8::',
                                :mask => 'ffff:ffff:ffff:ffff::',
                                :ipam => Subnet::IPAM_MODES[:db])
    assert_equal '2001:db8::1', subnet.unused_ip

    subnet.reload
    FactoryGirl.create(:nic_managed, :ip6 => '2001:db8::1', :subnet6_id => subnet.id, :host => host, :mac => '00:00:00:00:00:01')
    FactoryGirl.create(:nic_managed, :ip6 => '2001:db8::2', :subnet6_id => subnet.id, :host => host, :mac => '00:00:00:00:00:02')
    assert_equal '2001:db8::3', subnet.unused_ip
  end

  test "#known_ips includes all host and interfaces IPs assigned to this subnet" do
    subnet = FactoryGirl.create(:subnet_ipv6,
                                :name => 'my_subnet',
                                :network => '2001:db8::',
                                :cidr => 64,
                                :from => '2001:db8::10',
                                :to => '2001:db8::12',
                                :dns_primary => '2001:db8::2',
                                :gateway => '2001:db8::3',
                                :ipam => Subnet::IPAM_MODES[:db])
    host = FactoryGirl.create(:host, :subnet6 => subnet, :ip6 => '2001:db8::1')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet6 => subnet, :name => "", :ip6 => '2001:db8::4'

    assert_includes subnet.known_ips, '2001:db8::1'
    assert_includes subnet.known_ips, '2001:db8::2'
    assert_includes subnet.known_ips, '2001:db8::3'
    assert_includes subnet.known_ips, '2001:db8::4'
    assert_equal 4, subnet.known_ips.size
  end

  private

  def get_ip(subnet, i = 1)
    IPAddr.new(subnet.ipaddr.to_i + i, subnet.family).to_s
  end
end
