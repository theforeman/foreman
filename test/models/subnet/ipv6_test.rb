require 'test_helper'

class Subnet::Ipv6Test < ActiveSupport::TestCase
  should_not allow_value(Array.new(9, 'abcd').join(':')).for(:mask) # 45 characters
  should_not allow_value('2001:db8::1:').for(:network)
  should_not allow_value('2001:db8:abcde::1').for(:network)
  # Test smart proxies from Subnet are inherited
  should belong_to(:tftp)
  should belong_to(:dns)
  should belong_to(:dhcp)

  test "cidr setter should set the mask" do
    @subnet = FactoryGirl.build(:subnet_ipv6)
    @subnet.cidr = 64
    assert_equal 'ffff:ffff:ffff:ffff::', @subnet.mask
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

  test "#known_ips includes all host and interfaces IPs assigned to this subnet" do
    subnet = FactoryGirl.create(:subnet_ipv6, :name => 'my_subnet', :network => '2001:db8::', :dns_primary => '2001:db8::1', :gateway => '2001:db8::2', :ipam => IPAM::MODES[:db])
    host = FactoryGirl.create(:host, :subnet6 => subnet, :ip6 => '2001:db8::3')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet6 => subnet, :name => "", :ip6 => '2001:db8::4'

    assert_includes subnet.known_ips, '2001:db8::1'
    assert_includes subnet.known_ips, '2001:db8::2'
    assert_includes subnet.known_ips, '2001:db8::3'
    assert_includes subnet.known_ips, '2001:db8::4'
    assert_equal 4, subnet.known_ips.size
  end

  test "#known_ips returns host/interface IPs after creation" do
    subnet = FactoryGirl.create(:subnet_ipv6, :name => 'my_subnet', :network => '2001:db8::', :dns_primary => '2001:db8::1', :gateway => '2001:db8::2', :ipam => IPAM::MODES[:db])
    refute_includes subnet.known_ips, '2001:db8::3'
    refute_includes subnet.known_ips, '2001:db8::4'

    host = FactoryGirl.create(:host, :subnet6 => subnet, :ip6 => '2001:db8::3')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet6 => subnet, :name => "", :ip6 => '2001:db8::4'

    assert_includes subnet.known_ips, '2001:db8::3'
    assert_includes subnet.known_ips, '2001:db8::4'
  end

  private

  def get_ip(subnet, i = 1)
    IPAddr.new(subnet.ipaddr.to_i + i, subnet.family).to_s
  end
end
