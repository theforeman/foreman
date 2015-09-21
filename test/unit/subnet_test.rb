require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    @subnet = Subnet.new
    @attrs = {  :network= => "123.123.123.1",
      :mask= => "255.255.255.0",
      :domains= => [domains(:mydomain)],
      :name= => "valid" }
  end

  test "should have a network" do
    create_a_domain_with_the_subnet
    @subnet.network = nil
    assert !@subnet.save

    set_attr(:network=)
    assert @subnet.save
  end

  test "should have a mask" do
    create_a_domain_with_the_subnet
    @subnet.mask = nil
    assert !@subnet.save

    @subnet.mask = "255.255.255.0"
    assert @subnet.save
  end

  test "network should have ip format" do
    @subnet.network = "asf.fwe6.we6s.q1"
    set_attr(:mask=)
    assert !@subnet.save
  end

  test "mask should have ip format" do
    @subnet.mask = "asf.fwe6.we6s.q1"
    set_attr(:network=, :domains=, :name=)
    assert !@subnet.save
  end

  test "mask should have valid address" do
    @subnet.mask = "255.0.0.255"
    set_attr(:network=, :domains=, :name=)
    refute @subnet.save
  end

  test "network should be unique" do
    set_attr(:network=, :mask=, :domains=, :name=)
    @subnet.save

    other_subnet = Subnet.create(:network => "123.123.123.1", :mask => "255.255.255.0")
    assert !other_subnet.save
  end

  test "the name should be unique in the domain scope" do
    create_a_domain_with_the_subnet

    other_subnet = Subnet.new( :mask => "111.111.111.1",
                                 :network => "255.255.252.0",
                                 :name => "valid",
                                 :domain_ids => [domains(:mydomain).id] )
    assert !other_subnet.valid?
    assert !other_subnet.save
  end

  test "when to_label is applied should show the domain, the mask and network" do
    create_a_domain_with_the_subnet

    assert_equal "valid (123.123.123.1/24)", @subnet.to_label
  end

  test "should find the subnet by ip" do
    @subnet = Subnet.new(:network => "123.123.123.1",:mask => "255.255.255.0",:name => "valid")
    assert @subnet.save
    assert @subnet.domain_ids = [domains(:mydomain).id]
    assert_equal @subnet, Subnet.subnet_for("123.123.123.1")
  end

  def set_attr(*attr)
    attr.each do |param|
      @subnet.send param, @attrs[param]
    end
  end

  def create_a_domain_with_the_subnet
    @domain = Domain.find_or_create_by(name: "domain")
    @subnet = Subnet.new(:network => "123.123.123.1",:mask => "255.255.255.0",:name => "valid")
    assert @subnet.save
    assert @subnet.domain_ids = [domains(:mydomain).id]
    @subnet.save!
  end

  test "from cant be bigger than to range" do
    s      = subnets(:one)
    s.to   = "2.3.4.15"
    s.from = "2.3.4.17"
    assert !s.save
  end

  test "should be able to save ranges" do
    s=subnets(:one)
    s.from = "2.3.4.15"
    s.to   = "2.3.4.17"
    assert s.save
  end

  test "should not be able to save ranges if they dont belong to the subnet" do
    s=subnets(:one)
    s.from = "2.3.3.15"
    s.to   = "2.3.4.17"
    assert !s.save
  end

  test "should not be able to save ranges if one of them is missing" do
    s=subnets(:one)
    s.from = "2.3.4.15"
    assert !s.save
    s.to   = "2.3.4.17"
    assert s.save
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

  test "should not allow an address great than 15 characters" do
    s = subnets(:one)
    s.mask = "255.255.255.1111"
    refute s.save
    assert_match /maximum is 15 characters/, s.errors.full_messages.join("\n")
  end

  test "should invalidate addresses are indeed invalid" do
    s = subnets(:one)
    # trailing dot
    s.network = "100.101.102.103."
    refute s.valid?
    # more than 3 characters
    s.network = "1234.101.102.103"
    # missing dot
    s.network = "100101.102.103."
    refute s.valid?
    # greater than 255
    s.network = "300.300.300.0"
    refute s.valid?
    # missing number
    s.network = "100.101.102"
    refute s.valid?
    assert_equal "is invalid", s.errors[:network].first
  end

  # test module StripWhitespace which strips leading and trailing whitespace on :name field
  test "should strip whitespace on name" do
    s = Subnet.new(:name => '    ABC Network     ', :network => "10.10.20.1", :mask => "255.255.255.0")
    assert s.save!
    assert_equal "ABC Network", s.name
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

  test "should find unused IP on proxy if proxy is set" do
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.1.0')
    subnet.stubs(:dhcp? => true)
    subnet.stubs(:dhcp => mock('attribute', :url => 'proxy.example.com'))
    fake_proxy = mock("dhcp_proxy")
    fake_proxy.stubs(:unused_ip => {'ip' => '192.168.1.25'})
    subnet.stubs(:dhcp_proxy => fake_proxy)
    assert_equal '192.168.1.25', subnet.unused_ip
  end

  test "should find unused IP in internal DB if proxy is not set" do
    host = FactoryGirl.create(:host)
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.2.0',
                                :ipam => Subnet::IPAM_MODES[:db])
    subnet.stubs(:dhcp? => false)
    assert_equal '192.168.2.1', subnet.unused_ip

    subnet.reload
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.1', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:01')
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.2', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:02')
    assert_equal '192.168.2.3', subnet.unused_ip
  end

  test "should find unused IP excluding named values in internal DB if proxy is not set" do
    host = FactoryGirl.create(:host)
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.2.0',
                                :ipam => Subnet::IPAM_MODES[:db])
    subnet.stubs(:dhcp? => false)
    assert_equal '192.168.2.3', subnet.unused_ip(nil, ['192.168.2.1', '192.168.2.2'])

    subnet.reload
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.1', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:01')
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.2', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:02')
    assert_equal '192.168.2.4', subnet.unused_ip(nil, ['192.168.2.3'])
  end

  test "#unused should respect subnet from and to if it's set" do
    host = FactoryGirl.create(:host)
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :ipam => Subnet::IPAM_MODES[:db])
    subnet.stubs(:dhcp? => false)
    assert_equal '192.168.2.10', subnet.unused_ip

    subnet.reload
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.10', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:01')
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.11', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:02')
    assert_equal '192.168.2.12', subnet.unused_ip

    subnet.reload
    FactoryGirl.create(:nic_managed, :ip => '192.168.2.12', :subnet_id => subnet.id, :host => host, :mac => '00:00:00:00:00:03')
    assert_nil subnet.unused_ip
  end

  test "#unused does not suggest IP if mode is set to none" do
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12')
    subnet.stubs(:dhcp? => false, :ipam => Subnet::IPAM_MODES[:none])
    assert_nil subnet.unused_ip
  end

  test "#known_ips includes all host and interfaces IPs assigned to this subnet" do
    subnet = FactoryGirl.create(:subnet, :name => 'my_subnet', :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                :dns_primary => '192.168.2.2', :gateway => '192.168.2.3', :ipam => Subnet::IPAM_MODES[:db])
    host = FactoryGirl.create(:host, :subnet => subnet, :ip => '192.168.2.1')
    Nic::Managed.create :mac => "00:00:01:10:00:00", :host => host, :subnet => subnet, :name => "", :ip => '192.168.2.4'

    assert_includes subnet.known_ips, '192.168.2.1'
    assert_includes subnet.known_ips, '192.168.2.2'
    assert_includes subnet.known_ips, '192.168.2.3'
    assert_includes subnet.known_ips, '192.168.2.4'
    assert_equal 4, subnet.known_ips.size
  end
end
