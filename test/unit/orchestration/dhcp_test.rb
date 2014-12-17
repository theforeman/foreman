require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    User.current = users(:one)
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
    User.current = nil
  end

  test 'host_should_have_dhcp' do
    if unattended?
      h = FactoryGirl.create(:host, :with_dhcp_orchestration)
      assert h.valid?
      assert h.dhcp?, 'host.dhcp? does not return true'
      assert_instance_of Net::DHCP::Record, h.dhcp_record
      assert_equal h.name, h.dhcp_record.hostname
    end
  end

  test 'host_should_not_have_dhcp' do
    if unattended?
      h = FactoryGirl.create(:host)
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:ip_available?).never
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  test 'bmc_should_have_valid_dhcp_record' do
    if unattended?
      h = FactoryGirl.create(:host, :with_dhcp_orchestration)
      b = FactoryGirl.build(:nic_bmc, :ip => '10.0.0.10', :name => 'bmc')
      b.host   = h
      b.domain = domains(:mydomain)
      b.subnet = subnets(:five)
      assert b.dhcp?
      assert_equal "#{b.name}.#{b.domain.name}-#{b.mac}/#{b.ip}", b.dhcp_record.to_s
    end
  end

  test "DHCP record contains jumpstart attributes" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration,
                          :model => FactoryGirl.create(:model, :vendor_class => 'Sun-Fire-V210'))
    h.expects(:jumpstart?).at_least_once.returns(true)
    h.os.expects(:jumpstart_params).at_least_once.with(h.provision_interface, h.model.vendor_class).returns(:vendor => '<Sun-Fire-V210>')
    h.valid?
    d = h.provision_interface.dhcp_record
    assert_instance_of Net::DHCP::SparcRecord, d
    assert_equal '<Sun-Fire-V210>', d.vendor
  end

  test "provision interface DHCP records should contain filename/next-server attributes" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryGirl.build(:subnet, :dhcp, :tftp)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :with_tftp_orchestration, :subnet => subnet)
    assert_equal 'pxelinux.0', h.provision_interface.dhcp_record.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_record.nextServer
  end

  test "new host should create a dhcp reservation" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration)
    assert h.new_record?

    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action.last == :set_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
  end

  test "new host should create a BMC dhcp reservation" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration, :name => 'dummy-123')
    assert h.new_record?
    h.interfaces_attributes = [{ :name => "dummy-bmc", :ip => h.ip.succ, :mac => "aa:bb:cd:cd:ee:ff",
                                 :subnet_id => h.subnet_id, :provider => 'IPMI', :type => 'Nic::BMC', :domain_id => h.domain_id}]
    assert h.valid?

    bmc = h.interfaces.detect { |i| i.name =~ /^dummy-bmc/ }

    primary_interface_tasks = h.queue.items.select { |t| t.action.first == h.primary_interface }
    interface_tasks = h.queue.items.select { |t| t.action.first == bmc }

    assert_equal 1, primary_interface_tasks.select { |t| t.action.last == :set_dhcp }.size
    assert_empty primary_interface_tasks.select { |t| t.action.last == :del_dhcp }
    assert_equal 1, interface_tasks.select { |t| t.action.last == :set_dhcp }.size
    assert_empty interface_tasks.select  { |t| t.action.last == :del_dhcp }
  end

  test "when an existing host change its ip address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.ip = h.ip.succ
    assert h.valid?
    # 1st is creation from factory, 2nd is triggered by h.valid?
    assert_equal 2, h.queue.items.select {|x| x.action == [ h.primary_interface, :set_dhcp ] }.size
    # and also one deletion (of original creation)
    assert_equal 1, h.primary_interface.queue.items.select {|x| x.action.last == :del_dhcp }.size
  end

  test "when an existing host change its bmc ip address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create!(:host_id => h.id, :mac => "da:aa:aa:ab:db:bb", :domain_id => h.domain_id,
                       :ip => h.ip.succ, :subnet_id => h.subnet_id, :name => "bmc-#{h}", :provider => 'IPMI')
    end
    h.reload
    bmc = h.interfaces.bmc.first
    bmc.ip = bmc.ip.succ
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc, :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

  test "when an existing host change its mac address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.mac = next_mac(h.mac)
    assert h.valid?
    assert_equal 2, h.queue.items.select {|x| x.action == [ h.primary_interface, :set_dhcp ] }.size
    assert_equal 1, h.primary_interface.queue.items.select {|x| x.action.last == :del_dhcp }.size
  end

  test "when an existing host trigger a 'rebuild', its dhcp record should be updated if no dhcp record is found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(false)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)

    h.build = true

    assert h.valid?, h.errors.messages.to_s
    assert_equal 2, h.queue.items.select {|x| x.action == [ h.primary_interface, :set_dhcp ] }.size
    assert_equal 1, h.primary_interface.queue.items.select {|x| x.action.last == :del_dhcp }.size
  end

  test "when an existing host trigger a 'rebuild', its dhcp record should not be updated if valid dhcp record is found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(true)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)

    h.build = true

    assert h.valid?, h.errors.messages.to_s
    assert_equal 1, h.queue.items.select {|x| x.action == [ h.primary_interface, :set_dhcp ] }.size
    assert_equal 0, h.primary_interface.queue.items.select {|x| x.action.last == :del_dhcp }.size
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create! :host => h, :mac => "aa:aa:aa:ab:bd:bb", :ip => h.ip.succ, :domain => h.domain,
                       :subnet => h.subnet, :name => "bmc1-#{h}", :provider => 'IPMI'
    end
    h = Host.find h.id
    bmc = h.interfaces.bmc.first
    bmc.mac = next_mac(bmc.mac)
    assert h.valid?
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :mac => "aa:aa:ad:ab:bb:cc")
    as_admin do
      Nic::BMC.create!(:host => h, :mac => "aa:aa:ad:ab:bb:bb", :domain => h.domain, :subnet => h.subnet,
                       :name => "bmc-it", :provider => 'IPMI', :ip => h.ip.succ)
    end
    h = Host.find h.id
    h.mac = next_mac(h.mac)
    bmc = h.interfaces.bmc.first
    assert !bmc.new_record?
    bmc.mac = next_mac(bmc.mac)
    assert h.valid?
    assert bmc.valid?
    assert_equal 1, h.queue.items.select {|x| x.action == [ h.primary_interface, :set_dhcp ] }.size
    assert_equal 2, h.queue.items.select {|x| x.action.last == :del_dhcp }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

  test "new host with dhcp and no operating system should show correct validation on save" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration, :operatingsystem => nil)

    # If there was an exception due to accessing operating_system.boot_filename when operating_system is nil
    # this line would cause an error in the test
    refute h.valid?
    assert_equal h.errors[:operatingsystem_id].first, "can't be blank"
  end
end
