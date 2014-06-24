require 'test_helper'

class NicTest < ActiveSupport::TestCase

  def setup
    disable_orchestration
    User.current = User.admin
  end

  def teardown
    User.current = nil
  end

  test "should create simple interface" do
    i = ''
    i = Nic::Base.create! :mac => "cabbccddeeff", :host => hosts(:one)
    assert_equal "Nic::Base", i.class.to_s
  end

  test "type casting should return the correct class" do
    i = ''
    i = Nic::Base.create! :ip => "127.2.3.8", :mac => "babbccddeeff", :host => hosts(:one), :name => hosts(:one).name, :type => "Nic::Interface"
    assert_equal "Nic::Interface", i.type
  end

  test "should fail on invalid mac" do
    i = Nic::Base.new :mac => "abccddeeff", :host => hosts(:one)
    assert !i.valid?
    assert i.errors.keys.include?(:mac)
  end

  test "should be valid with 64-bit mac address" do
    i = Nic::Base.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => hosts(:one)
    assert i.valid?
    assert !i.errors.keys.include?(:mac)
  end

  test "should fail on invalid dns name" do
    i = Nic::Managed.new :mac => "dabbccddeeff", :host => hosts(:one), :name => "invalid_dns_name"
    assert !i.valid?
    assert i.errors.keys.include?(:name)
  end

  test "should fix mac address" do
    interface = Nic::Base.create! :mac => "cabbccddeeff", :host => hosts(:one)
    assert_equal "ca:bb:cc:dd:ee:ff", interface.mac
  end

  test "should fix 64-bit mac address" do
    interface = Nic::Base.create! :mac => "babbccddeeff00112233445566778899aabbccdd", :host => hosts(:one)
    assert_equal "ba:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", interface.mac
  end

  test "should fix ip address if a leading zero is used" do
    interface = Nic::Interface.create! :ip => "123.01.02.03", :mac => "dabbccddeeff", :host => hosts(:one), :name => hosts(:one).name
    assert_equal "123.1.2.3", interface.ip
  end

  test "should delegate subnet attributes" do
    subnet = subnets(:one)
    domain = (subnet.domains.any? ? subnet.domains : subnet.domains << Domain.first).first
    interface = Nic::Managed.create! :ip => "2.3.4.127", :mac => "cabbccddeeff", :host => hosts(:one), :subnet => subnet, :name => "a" + hosts(:one).name, :domain => domain
    assert_equal subnet.network, interface.network
    assert_equal subnet.vlanid, interface.vlanid
  end

  test "Nic::BMC should have hostname containing name and domain name" do
    subnet = subnets(:five)
    domain = domains(:mydomain)
    interface = nics(:bmc)
    interface.subnet = subnet
    interface.domain = domain
    assert_equal "#{interface.name}.#{interface.domain.name}", interface.hostname
  end

  test "Nic::BMC should have hostname containing name when domain nil" do
    subnet = subnets(:five)
    interface = nics(:bmc)
    interface.subnet = subnet
    interface.domain = nil
    assert_equal interface.name, interface.hostname
  end

  test "Nic::Managed#hostname should return blank for blank hostnames" do
    i = Nic::Managed.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => hosts(:one), :subnet => subnets(:one), :domain => subnets(:one).domains.first, :name => ""
    assert_blank i.name
    assert_present i.domain
    assert_blank i.hostname
  end
end
