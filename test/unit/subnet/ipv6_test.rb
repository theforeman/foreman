require 'test_helper'

class Subnet::Ipv6Test < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"
  end

  should_not allow_value(9.times.map { 'abcd' }.join(':')).for(:mask) # 45 characters
  should_not allow_value('2001:db8::1:').for(:network)
  should_not allow_value('2001:db8:abcde::1').for(:network)

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

  private

  def get_ip(subnet, i = 1)
    IPAddr.new(subnet.ipaddr.to_i + i, subnet.family).to_s
  end
end
