require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  should validate_presence_of(:network)
  should validate_presence_of(:mask)
  should validate_presence_of(:mtu)
  should_not allow_value(60).for(:mtu)
  should_not validate_uniqueness_of(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:mask)
  should allow_values(10, 100, '200', nil, '').for(:vlanid)
  should_not allow_value('Bär', -12, 4096).for(:vlanid)
  should belong_to(:tftp)
  should belong_to(:dns)
  should belong_to(:dhcp)

  test 'should sort by vlanid as number' do
    # ensure we have subnets that would be incorrectly sorted in text sort
    FactoryBot.create(:subnet_ipv4, vlanid: 3)
    FactoryBot.create(:subnet_ipv4, vlanid: 33)
    FactoryBot.create(:subnet_ipv4, vlanid: 4)
    vlanids = Subnet.all.pluck(:vlanid).reject(&:nil?)
    assert_equal vlanids, vlanids.map(&:to_i).sort
  end

  test 'should be cast to Subnet::Ipv4 if no type is set' do
    subnet = Subnet.new
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'should be cast to Subnet::Ipv4 if type is set' do
    subnet = Subnet.new(:type => 'Subnet::Ipv4')
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'should be cast to Subnet::Ipv6 if type is set accordingly' do
    subnet = Subnet.new(:type => 'Subnet::Ipv6')
    assert_equal Subnet::Ipv6, subnet.class
  end

  test 'child class should not be cast to default sti class even if no type is set' do
    class Subnet::Test < Subnet; end
    subnet = Subnet::Test.new
    assert_equal Subnet::Test, subnet.class
  end

  test '#network_type returns the subnets type in human friendly form' do
    subnet = Subnet.new(:type => 'Subnet::Ipv4')
    assert_equal 'IPv4', subnet.network_type
    subnet6 = Subnet.new(:type => 'Subnet::Ipv6')
    assert_equal 'IPv6', subnet6.network_type
  end

  test '#network_type= should set #type' do
    subnet = Subnet.new(:type => 'Subnet::Ipv4')
    subnet.network_type = 'IPv6'
    assert_equal 'Subnet::Ipv6', subnet.type
  end

  test '.new_network_type instantiates network_type from arguments' do
    assert_instance_of Subnet::Ipv6, Subnet.new_network_type(:network_type => 'IPv6')
  end

  test '.new_network_type raises error for unknown network type' do
    e = assert_raise(Foreman::Exception) { Subnet.new_network_type({:network_type => 'Unknown'}) }
    assert_match /unknown network_type/, e.message
  end

  test "the name should be unique in the domain scope" do
    first = FactoryBot.create(:subnet_ipv6, :with_domains)
    subnet = FactoryBot.build_stubbed(:subnet_ipv6, :name => first.name, :domains => first.domains)
    refute subnet.valid?
  end

  test "when to_label is applied should show the domain, the mask and network" do
    subnet = FactoryBot.create(:subnet_ipv4,
      :with_domains,
      :name => 'valid',
      :network => '123.123.123.0',
      :mask => '255.255.255.0'
    )

    assert_equal "valid (123.123.123.0/24)", subnet.to_label
  end

  # test module StripWhitespace which strips leading and trailing whitespace on :name field
  test "should strip whitespace on name" do
    s = FactoryBot.build(:subnet_ipv6, :name => '    ABC Network     ')
    assert s.save!
    assert_equal "ABC Network", s.name
  end

  test "should strip whitespace before save" do
    s = subnets(:one)
    s.network = " 10.0.0.22   "
    s.mask = " 255.255.255.0   "
    s.gateway = " 10.0.0.138   "
    s.dns_primary = " 10.0.0.50   "
    s.dns_secondary = " 10.0.0.60   "
    assert s.save
    assert_equal "10.0.0.22", s.network
    assert_equal "255.255.255.0", s.mask
    assert_equal "10.0.0.138", s.gateway
    assert_equal "10.0.0.50", s.dns_primary
    assert_equal "10.0.0.60", s.dns_secondary
  end

  test "should not destroy if hostgroup uses it" do
    hostgroup = FactoryBot.create(:hostgroup, :with_subnet)
    subnet = hostgroup.subnet
    refute subnet.destroy
    assert_match /is used by/, subnet.errors.full_messages.join("\n")
  end

  test "should not destroy if host uses it" do
    host = FactoryBot.create(:host, :with_subnet)
    subnet = host.subnet
    refute subnet.destroy
    assert_match /is used by/, subnet.errors.full_messages.join("\n")
  end

  test "should have MTU set to 1500 by default" do
    assert_equal 1500, Subnet.new.mtu
  end

  test "should have nic_delay set to nil by default" do
    assert_nil Subnet.new.nic_delay
  end

  describe '#dns_servers' do
    test 'should display a list of dns servers' do
      subnet = FactoryBot.create(:subnet_ipv4, dns_primary: '192.0.2.1', dns_secondary: '192.0.2.2')
      assert_equal ['192.0.2.1', '192.0.2.2'], subnet.dns_servers
    end

    test 'should skip empty dns servers' do
      subnet = FactoryBot.create(:subnet_ipv4, dns_secondary: '192.0.2.1')
      assert_equal ['192.0.2.1'], subnet.dns_servers
    end

    test 'should display an empty list if no dns servers are present' do
      subnet = FactoryBot.create(:subnet_ipv4)
      assert_equal [], subnet.dns_servers
    end
  end
end
