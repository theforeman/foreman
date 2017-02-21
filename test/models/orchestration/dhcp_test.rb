require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    User.current = users(:one)
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
    skip_without_unattended
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
    User.current = nil
  end

  test 'host_should_have_dhcp' do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    assert h.valid?
    assert h.dhcp?, 'host.dhcp? does not return true'
    assert_equal 1, h.dhcp_records.size
    assert_kind_of Array, h.dhcp_records
    assert_instance_of Net::DHCP::Record, h.dhcp_records.first
    assert_equal h.name, h.dhcp_records.first.hostname
  end

  test 'host_should_not_have_dhcp' do
    h = FactoryGirl.create(:host)
    assert h.valid?
    assert_equal false, h.dhcp?
    assert_equal [], h.dhcp_records
  end

  test 'unmanaged should not call methods after managed?' do
    h = FactoryGirl.create(:host)
    Nic::Managed.any_instance.expects(:ip_available?).never
    assert h.valid?
    assert_equal false, h.dhcp?
  end

  test 'bmc_should_have_valid_dhcp_record' do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    b = FactoryGirl.build(:nic_bmc, :ip => '10.0.0.10', :name => 'bmc')
    b.host   = h
    b.domain = domains(:mydomain)
    b.subnet = subnets(:five)
    assert b.dhcp?
    assert_equal 1, b.dhcp_records.size
    assert_equal "#{b.name}.#{b.domain.name}-#{b.mac}/#{b.ip}", b.dhcp_records.first.to_s
  end

  test 'static boot mode still enables dhcp orchestration' do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration)
    i = FactoryGirl.build(:nic_managed, :ip => '10.0.0.10', :name => 'eth0:0')
    i.host   = h
    i.domain = domains(:mydomain)
    i.subnet = FactoryGirl.build(:subnet_ipv4, :dhcp, :boot_mode => 'Static', :ipam => 'Internal DB')
    assert i.dhcp?
  end

  test "DHCP record contains jumpstart attributes" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration,
                          :model => FactoryGirl.create(:model, :vendor_class => 'Sun-Fire-V210'))
    h.expects(:jumpstart?).at_least_once.returns(true)
    h.os.expects(:jumpstart_params).at_least_once.with(h, h.model.vendor_class).returns(:vendor => '<Sun-Fire-V210>')
    h.valid?
    assert_equal 1, h.provision_interface.dhcp_records.size
    d = h.provision_interface.dhcp_records.first
    assert_instance_of Net::DHCP::SparcRecord, d
    assert_equal '<Sun-Fire-V210>', d.vendor
  end

  test "provision interface DHCP records should contain default filename/next-server attributes for IPv4 tftp proxy" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryGirl.build(:subnet_ipv4, :dhcp, :tftp)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :with_tftp_dual_stack_orchestration, :subnet => subnet)
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_equal 'grub2/grubx64.efi', h.provision_interface.dhcp_records.first.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_records.first.nextServer
  end

  test "provision interface DHCP records should contain explicit filename/next-server attributes for IPv4 tftp proxy" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryGirl.build(:subnet_ipv4, :dhcp, :tftp)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :with_tftp_dual_stack_orchestration, :subnet => subnet, :pxe_loader => 'PXELinux BIOS')
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_equal 'pxelinux.0', h.provision_interface.dhcp_records.first.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_records.first.nextServer
  end

  test "provision interface DHCP records should not contain explicit filename attribute when PXE loader is set to None" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryGirl.build(:subnet_ipv4, :dhcp, :tftp)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :with_tftp_orchestration, :subnet => subnet, :pxe_loader => 'None')
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_nil h.provision_interface.dhcp_records.first.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_records.first.nextServer
  end

  context 'host with bond interface' do
    let(:subnet) do
      FactoryGirl.build(:subnet_ipv4, :dhcp, :with_taxonomies)
    end
    let(:interfaces) do
      [
        FactoryGirl.build(:nic_bond, :primary => true,
                          :identifier => 'bond0',
                          :attached_devices => ['eth0', 'eth1'],
                          :provision => true,
                          :domain => FactoryGirl.build(:domain),
                          :subnet => subnet,
                          :mac => nil,
                          :ip => subnet.network.sub(/0\Z/, '2')),
        FactoryGirl.build(:nic_interface,
                          :identifier => 'eth0',
                          :mac => '00:53:67:ab:dd:00'
                         ),
        FactoryGirl.build(:nic_interface,
                          :identifier => 'eth1',
                          :mac => '00:53:67:ab:dd:01'
                         )
      ]
    end
    let(:host) do
      FactoryGirl.create(:host,
                         :with_dhcp_orchestration,
                         :subnet => subnet,
                         :interfaces => interfaces,
                         :build => true,
                         :location => subnet.locations.first,
                         :organization => subnet.organizations.first)
    end

    test 'should have two dhcp records' do
      assert_equal true, host.provision_interface.mac_available?
      assert_equal true, host.dhcp?
      assert_equal 2, host.dhcp_records.size

      # Record 1
      assert_equal '00:53:67:ab:dd:00', host.dhcp_records.first.mac
      assert_equal host.hostname, host.dhcp_records.first.hostname
      assert_equal "#{host.name}-01", host.dhcp_records.first.name

      # Record 2
      assert_equal '00:53:67:ab:dd:01', host.dhcp_records.last.mac
      assert_equal host.hostname, host.dhcp_records.last.hostname
      assert_equal "#{host.name}-02", host.dhcp_records.last.name
    end

    test 'the records should not be conflicting' do
      Net::DHCP::Record.any_instance.unstub(:conflicting?)
      ProxyAPI::DHCP.any_instance.stubs(:record).with(subnet.network, host.dhcp_records.first.mac).returns(host.dhcp_records.first)
      ProxyAPI::DHCP.any_instance.stubs(:records_by_ip).with(subnet.network, host.provision_interface.ip).returns([host.dhcp_records.first, host.dhcp_records.last])
      ProxyAPI::DHCP.any_instance.stubs(:record).with(subnet.network, host.dhcp_records.last.mac).returns(host.dhcp_records.last)
      refute host.dhcp_records.first.conflicting?
      refute host.dhcp_records.last.conflicting?
    end

    test '#set_dhcp should provision dhcp for all bond child macs' do
      dhcp_proxy = mock()
      subnet.stubs(:dhcp_proxy).returns(dhcp_proxy)
      dhcp_proxy.expects(:set).with(
        subnet.network,
        host.dhcp_records.first.attrs
      ).once.returns(true)
      dhcp_proxy.expects(:set).with(
        subnet.network,
        host.dhcp_records.last.attrs
      ).once.returns(true)

      Net::DHCP::Record.any_instance.unstub(:create)
      assert host.provision_interface.send(:set_dhcp)
    end

    test 'should queue an update when mac of child interface changes' do
      host.save
      host.queue.clear
      host.interfaces.last.mac = next_mac(host.interfaces.last.mac)
      assert host.interfaces.all?(&:save)
      assert_valid host
      tasks = host.queue.all.map(&:name)
      assert_includes tasks, "Remove DHCP Settings for #{host.provision_interface}"
      assert_includes tasks, "Create DHCP Settings for #{host.provision_interface}"
      assert_equal 2, tasks.size
    end
  end

  test "new host should create a dhcp reservation" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration)
    assert h.new_record?

    assert h.valid?
    assert_equal h.queue.items.count {|x| x.action.last == :set_dhcp }, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
  end

  test "queue_dhcp doesn't fail when mac address is blank but provided by compute resource" do
    cr = FactoryGirl.build(:libvirt_cr)
    cr.stubs(:provided_attributes).returns({:mac => :mac})
    host = FactoryGirl.build(:host, :with_dhcp_orchestration, :compute_resource => cr)
    interface = host.interfaces.first
    interface.mac = nil
    interface.stubs(:dhcp? => true, :overwrite? => true)

    assert interface.send(:queue_dhcp)
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

    assert_equal 1, primary_interface_tasks.count { |t| t.action.last == :set_dhcp }
    assert_empty primary_interface_tasks.select { |t| t.action.last == :del_dhcp }
    assert_equal 1, interface_tasks.count { |t| t.action.last == :set_dhcp }
    assert_empty interface_tasks.select { |t| t.action.last == :del_dhcp }
  end

  test "when an existing host changes its ip address, its dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.ip = h.ip.succ
    assert h.valid?
    # 1st is creation from factory, 2nd is triggered by h.valid?
    assert_equal 2, h.queue.items.count {|x| x.action == [ h.primary_interface, :set_dhcp ] }
    # and also one deletion (of original creation)
    assert_equal 1, h.primary_interface.queue.items.count {|x| x.action.last == :del_dhcp }
  end

  test "when an existing host change its bmc ip address, its dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create!(:host_id => h.id, :mac => "da:aa:aa:ab:db:bb", :domain_id => h.domain_id,
                       :ip => h.ip.succ, :subnet_id => h.subnet_id, :name => "bmc-#{h}", :provider => 'IPMI')
    end
    h.reload
    bmc = h.interfaces.bmc.first
    bmc.ip = bmc.ip.succ
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc, :set_dhcp ] }
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp ] }
  end

  test "when an existing host changes its mac address, its dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.mac = next_mac(h.mac)
    assert h.valid?
    assert_equal 2, h.queue.items.count {|x| x.action == [ h.primary_interface, :set_dhcp ] }
    assert_equal 1, h.primary_interface.queue.items.count {|x| x.action.last == :del_dhcp }
  end

  test "when an existing host triggers a 'rebuild', its dhcp records should be updated if no dhcp records are found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(false)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)

    h.build = true

    assert h.valid?, h.errors.messages.to_s
    assert_equal 2, h.queue.items.count {|x| x.action == [ h.primary_interface, :set_dhcp ] }
    assert_equal 1, h.primary_interface.queue.items.count {|x| x.action.last == :del_dhcp }
  end

  test "when an existing host trigger a 'rebuild', its dhcp records should not be updated if valid dhcp records are found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(true)
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)

    h.build = true

    assert h.valid?, h.errors.messages.to_s
    assert_equal 1, h.queue.items.count {|x| x.action == [ h.primary_interface, :set_dhcp ] }
    assert_equal 0, h.primary_interface.queue.items.count {|x| x.action.last == :del_dhcp }
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create! :host => h, :mac => "aa:aa:aa:ab:bd:bb", :ip => h.ip.succ, :domain => h.domain,
                       :subnet => h.subnet, :name => "bmc1-#{h}", :provider => 'IPMI'
    end
    h = Host.find(h.id)
    bmc = h.interfaces.bmc.first
    bmc.mac = next_mac(bmc.mac)
    assert h.valid?
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc,     :set_dhcp ] }
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp ] }
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration, :mac => "aa:aa:ad:ab:bb:cc")
    as_admin do
      Nic::BMC.create!(:host => h, :mac => "aa:aa:ad:ab:bb:bb", :domain => h.domain, :subnet => h.subnet,
                       :name => "bmc-it", :provider => 'IPMI', :ip => h.ip.succ)
    end
    h.reload
    h.mac = next_mac(h.mac)
    bmc = h.interfaces.bmc.first.reload
    assert !bmc.new_record?
    bmc.mac = next_mac(bmc.mac)
    assert h.valid?
    assert bmc.valid?
    assert_equal 2, h.queue.items.count {|x| x.action == [ h.primary_interface, :set_dhcp ] }
    assert_equal 1, h.queue.items.count {|x| x.action.last == :del_dhcp }
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc,     :set_dhcp ] }
    assert_equal 1, bmc.queue.items.count {|x| x.action == [ bmc.old, :del_dhcp ] }
  end

  test "new host with dhcp and no operating system should show correct validation on save" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration, :operatingsystem => nil)

    # If there was an exception due to accessing operating_system.boot_filename when operating_system is nil
    # this line would cause an error in the test
    refute h.valid?
    assert_equal h.errors[:operatingsystem_id].first, "can't be blank"
  end

  test "should rebuild dhcp" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    Nic::Managed.any_instance.expects(:del_dhcp)
    Nic::Managed.any_instance.expects(:set_dhcp).returns(true)
    assert h.interfaces.first.rebuild_dhcp
  end

  test "should skip dhcp rebuild" do
    nic = FactoryGirl.build(:nic_managed)
    nic.expects(:set_dhcp).never
    assert nic.rebuild_dhcp
  end

  test "should fail with exception" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    Nic::Managed.any_instance.expects(:del_dhcp)
    Nic::Managed.any_instance.expects(:set_dhcp).raises(StandardError, 'DHCP test failure')
    refute h.interfaces.first.rebuild_dhcp
  end

  test "dhcp_records should return nil for invalid mac" do
    host = FactoryGirl.build(:host, :with_dhcp_orchestration, :interfaces => [FactoryGirl.build(:nic_primary_and_provision, :mac => "aaaaaa")])
    assert_nil host.dhcp_records.first
  end

  context '#boot_server' do
    let(:host) { FactoryGirl.build(:host, :managed, :with_tftp_orchestration) }
    let(:nic) { host.provision_interface }

    test 'should use boot server provided by proxy' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
      assert_equal '127.13.0.1', nic.send(:boot_server)
    end

    test 'should use boot server based on proxy url' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns(nil)
      Resolv::DNS.any_instance.expects(:getaddress).once.returns("127.12.0.1")
      assert_equal '127.12.0.1', nic.send(:boot_server)
    end
  end
end
