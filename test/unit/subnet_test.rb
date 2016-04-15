require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  should validate_presence_of(:network)
  should validate_presence_of(:mask)
  should validate_uniqueness_of(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:mask)

  test 'should be cast to Subnet::Ipv4 if no type is set' do
    subnet = Subnet.new
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'should be cast to Subnet::Ipv4 if type is set' do
    subnet = Subnet.new(:type => 'Subnet::Ipv4')
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'child class should not be cast to default sti class even if no type is set' do
    class Subnet::Test < Subnet; end
    subnet = Subnet::Test.new
    assert_equal Subnet::Test, subnet.class
  end

  test "the name should be unique in the domain scope" do
    first = FactoryGirl.create(:subnet_ipv6, :with_domains)
    subnet = FactoryGirl.build(:subnet_ipv6, :name => first.name, :domains => first.domains)
    refute subnet.valid?
  end

  test "when to_label is applied should show the domain, the mask and network" do
    subnet = FactoryGirl.create(:subnet_ipv4,
                                :with_domains,
                                :name => 'valid',
                                :network => '123.123.123.0',
                                :mask => '255.255.255.0',
                               )

    assert_equal "valid (123.123.123.0/24)", subnet.to_label
  end

  # test module StripWhitespace which strips leading and trailing whitespace on :name field
  test "should strip whitespace on name" do
    s = FactoryGirl.build(:subnet_ipv6, :name => '    ABC Network     ')
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
    hostgroup = FactoryGirl.create(:hostgroup, :with_subnet)
    subnet = hostgroup.subnet
    refute subnet.destroy
    assert_match /is being used by/, subnet.errors.full_messages.join("\n")
  end

  test "should not destroy if host uses it" do
    host = FactoryGirl.create(:host, :with_subnet)
    subnet = host.subnet
    refute subnet.destroy
    assert_match /is used by/, subnet.errors.full_messages.join("\n")
  end
end
