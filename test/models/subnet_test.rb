require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  should validate_presence_of(:network)
  should validate_presence_of(:mask)
  should_not validate_uniqueness_of(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:network)
  should_not allow_value("asf:fwe6::we6s:q1").for(:mask)
  should belong_to(:tftp)
  should belong_to(:dns)
  should belong_to(:dhcp)

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
    first = FactoryGirl.create(:subnet_ipv6, :with_domains)
    subnet = FactoryGirl.build(:subnet_ipv6, :name => first.name, :domains => first.domains)
    refute subnet.valid?
  end

  test "when to_label is applied should show the domain, the mask and network" do
    subnet = FactoryGirl.create(:subnet_ipv4,
                                :with_domains,
                                :name => 'valid',
                                :network => '123.123.123.0',
                                :mask => '255.255.255.0'
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
    assert_match /is used by/, subnet.errors.full_messages.join("\n")
  end

  test "should not destroy if host uses it" do
    host = FactoryGirl.create(:host, :with_subnet)
    subnet = host.subnet
    refute subnet.destroy
    assert_match /is used by/, subnet.errors.full_messages.join("\n")
  end

  test 'smart variable matches on subnet name' do
    host = FactoryGirl.create(:host, :with_subnet, :puppetclasses => [puppetclasses(:one)])
    subnet = host.subnet
    key = FactoryGirl.create(:variable_lookup_key, :key_type => 'string',
                             :default_value => 'default', :path => "subnet",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "subnet=#{subnet.name}",
                          :value => 'subnet'
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value.value,
                                         :element => 'subnet',
                                         :element_name => subnet.name}}},
                 Classification::GlobalParam.new(:host => host).send(:values_hash))
  end
end
