require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    skip_without_unattended
  end

  test 'host_should_have_dhcp' do
    h = FactoryBot.create(:host, :with_dhcp_orchestration)
    assert h.valid?
    assert h.dhcp?, 'host.dhcp? does not return true'
    assert_equal 1, h.dhcp_records.size
    assert_kind_of Array, h.dhcp_records
    assert_instance_of Net::DHCP::Record, h.dhcp_records.first
    assert_equal h.name, h.dhcp_records.first.hostname
  end

  test 'host_should_not_have_dhcp' do
    h = FactoryBot.create(:host)
    assert h.valid?
    assert_equal false, h.dhcp?
    assert_equal [], h.dhcp_records
  end

  test 'unmanaged should not call methods after managed?' do
    h = FactoryBot.create(:host)
    Nic::Managed.any_instance.expects(:ip_available?).never
    assert h.valid?
    assert_equal false, h.dhcp?
  end

  test 'bmc_should_have_valid_dhcp_record' do
    h = FactoryBot.create(:host, :with_dhcp_orchestration)
    b = FactoryBot.build_stubbed(:nic_bmc, :ip => '10.0.0.10', :name => 'bmc')
    b.host   = h
    b.domain = domains(:mydomain)
    b.subnet = subnets(:five)
    assert b.dhcp?
    assert_equal 1, b.dhcp_records.size
    assert_equal "#{b.name}.#{b.domain.name}-#{b.mac}/#{b.ip}", b.dhcp_records.first.to_s
  end

  test 'static boot mode still enables dhcp orchestration' do
    h = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration)
    i = FactoryBot.build_stubbed(:nic_managed, :ip => '10.0.0.10', :name => 'eth0:0')
    i.host   = h
    i.domain = domains(:mydomain)
    i.subnet = FactoryBot.build_stubbed(:subnet_ipv4, :dhcp, :boot_mode => 'Static', :ipam => 'Internal DB')
    assert i.dhcp?
  end

  test "DHCP record contains jumpstart attributes" do
    h = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration,
      :model => FactoryBot.create(:model, :vendor_class => 'Sun-Fire-V210'))
    h.expects(:jumpstart?).at_least_once.returns(true)
    h.os.expects(:dhcp_record_type).at_least_once.returns(Net::DHCP::SparcRecord)
    h.os.expects(:jumpstart_params).at_least_once.with(h, h.model.vendor_class).returns(:vendor => '<Sun-Fire-V210>')
    h.valid?
    assert_equal 1, h.provision_interface.dhcp_records.size
    d = h.provision_interface.dhcp_records.first
    assert_instance_of Net::DHCP::SparcRecord, d
    assert_equal '<Sun-Fire-V210>', d.vendor
  end

  test "DHCP record contains ztp attributes" do
    h = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration)
    h.os.expects(:pxe_type).at_least_once.returns("ZTP")
    h.os.expects(:dhcp_record_type).at_least_once.returns(Net::DHCP::ZTPRecord)
    h.os.expects(:ztp_arguments).at_least_once.with(h).returns(:vendor => 'huawei', :firmware => {:core => "firmware.cc", :web => "web.7z"})
    h.valid?
    assert_equal 1, h.provision_interface.dhcp_records.size
    d = h.provision_interface.dhcp_records.first
    assert_instance_of Net::DHCP::ZTPRecord, d
    assert_equal 'huawei', d.vendor
    assert_equal 'firmware.cc', d.firmware[:core]
    assert_equal 'web.7z', d.firmware[:web]
  end

  test "DHCP record fallback if ZTP OS has no ztp attributes" do
    h = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration)
    h.os.expects(:pxe_type).at_least_once.returns("ZTP")
    h.valid?
    assert_equal 1, h.provision_interface.dhcp_records.size
    d = h.provision_interface.dhcp_records.first
    assert_instance_of Net::DHCP::Record, d
  end

  test "provision interface DHCP records should contain default filename/next-server attributes for IPv4 tftp proxy" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryBot.build(:subnet_ipv4, :dhcp, :tftp)
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :with_tftp_dual_stack_orchestration, :subnet => subnet)
    end
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_equal 'grub2/grubx64.efi', h.provision_interface.dhcp_records.first.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_records.first.nextServer
  end

  test "provision interface DHCP records should contain PXELinux BIOS filename/next-server attributes for IPv4 tftp proxy" do
    ProxyAPI::TFTP.any_instance.expects(:bootServer).returns('192.168.1.1')
    subnet = FactoryBot.build(:subnet_ipv4, :dhcp, :tftp)
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :with_tftp_dual_stack_orchestration, :subnet => subnet, :pxe_loader => 'PXELinux BIOS')
    end
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_equal 'pxelinux.0', h.provision_interface.dhcp_records.first.filename
    assert_equal '192.168.1.1', h.provision_interface.dhcp_records.first.nextServer
  end

  context "provision interface DHCP filename option" do
    context "for IPv4" do
      setup do
        ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('192.168.1.1')
      end

      def host_with_loader(loader)
        subnet = FactoryBot.build(:subnet_ipv4, :dhcp, :tftp, :httpboot)
        subnet.httpboot.stubs(:setting).returns(1234)
        as_admin do
          FactoryBot.create(:host, :with_tftp_orchestration_and_httpboot, :subnet => subnet, :pxe_loader => loader)
        end
      end

      test "with PXELinux BIOS" do
        assert_equal 'pxelinux.0', host_with_loader('PXELinux BIOS').provision_interface.dhcp_records.first.filename
      end

      test "with PXELinux UEFI" do
        assert_equal 'pxelinux.efi', host_with_loader('PXELinux UEFI').provision_interface.dhcp_records.first.filename
      end

      test "with Grub UEFI" do
        assert_equal 'grub/grubx64.efi', host_with_loader('Grub UEFI').provision_interface.dhcp_records.first.filename
      end

      test "with Grub2 UEFI" do
        assert_equal 'grub2/grubx64.efi', host_with_loader('Grub2 UEFI').provision_interface.dhcp_records.first.filename
      end

      test "with Grub2 UEFI SecureBoot" do
        assert_equal 'grub2/shimx64.efi', host_with_loader('Grub2 UEFI SecureBoot').provision_interface.dhcp_records.first.filename
      end

      test "with Grub2 UEFI HTTP without httpboot feature" do
        subnet = FactoryBot.build(:subnet_ipv4, :dhcp, :tftp, :httpboot)
        subnet.httpboot.stubs(:setting).returns(1234)
        host = as_admin do
          FactoryBot.create(:host, :with_tftp_orchestration_and_httpboot, :subnet => subnet, :pxe_loader => 'Grub2 UEFI HTTP')
        end
        assert_match(%r"http://somewhere\d+.net:1234/httpboot/grub2/grubx64.efi", host.provision_interface.dhcp_records.first.filename)
      end

      test "host has httpboot proxy" do
        assert host_with_loader('Grub2 UEFI HTTP').subnet.httpboot?
      end

      test "with Grub2 UEFI HTTP" do
        assert_match(%r"http://somewhere\d+.net:1234/httpboot/grub2/grubx64.efi", host_with_loader('Grub2 UEFI HTTP').provision_interface.dhcp_records.first.filename)
      end

      test "with Grub2 UEFI HTTPS" do
        assert_match(%r"https://somewhere\d+.net:1234/httpboot/grub2/grubx64.efi", host_with_loader('Grub2 UEFI HTTPS').provision_interface.dhcp_records.first.filename)
      end

      test "with Grub2 UEFI HTTPS SecureBoot" do
        assert_match(%r"https://somewhere\d+.net:1234/httpboot/grub2/shimx64.efi", host_with_loader('Grub2 UEFI HTTPS SecureBoot').provision_interface.dhcp_records.first.filename)
      end

      test "with iPXE UEFI HTTP" do
        assert_match(%r"http://somewhere\d+.net:1234/httpboot/ipxe-x64.efi", host_with_loader('iPXE UEFI HTTP').provision_interface.dhcp_records.first.filename)
      end
    end
  end

  test "provision interface DHCP records should not contain explicit filename and next server when PXE loader is set to None" do
    subnet = FactoryBot.build(:subnet_ipv4, :dhcp, :tftp)
    h = FactoryBot.create(:host, :with_dhcp_orchestration, :with_tftp_orchestration, :subnet => subnet, :pxe_loader => 'None')
    assert_equal 1, h.provision_interface.dhcp_records.size
    assert_nil h.provision_interface.dhcp_records.first.filename
    assert_nil h.provision_interface.dhcp_records.first.nextServer
  end

  context 'host with bond interface' do
    let(:subnet) do
      FactoryBot.build(:subnet_ipv4, :dhcp, :with_taxonomies)
    end
    let(:interfaces) do
      [
        FactoryBot.build(:nic_bond, :primary => true,
                          :identifier => 'bond0',
                          :attached_devices => ['eth0', 'eth1'],
                          :provision => true,
                          :domain => FactoryBot.build(:domain),
                          :subnet => subnet,
                          :mac => '00:53:67:ab:dd:00',
                          :ip => subnet.network.sub(/0\Z/, '2')),
        FactoryBot.build(:nic_interface,
          :identifier => 'eth0',
          :mac => '00:53:67:ab:dd:00'
        ),
        FactoryBot.build(:nic_interface,
          :identifier => 'eth1',
          :mac => '00:53:67:ab:dd:01'
        ),
      ]
    end
    let(:host) do
      as_admin do
        FactoryBot.create(:host,
          :with_dhcp_orchestration,
          :compute_resource => nil,
          :subnet => subnet,
          :interfaces => interfaces,
          :build => true,
          :location => subnet.locations.first,
          :organization => subnet.organizations.first)
      end
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
    h = FactoryBot.build(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:ff")
    assert h.new_record?
    assert h.valid?
    assert_equal ["dhcp_create_aa:bb:cc:dd:ee:ff"], h.queue.task_ids
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cc:dd:ee:ff").action.last
  end

  test "new host with multiple validations should create a single dhcp reservation" do
    h = FactoryBot.build(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:ff")
    assert h.new_record?
    assert h.valid?
    assert h.valid?
    assert_equal ["dhcp_create_aa:bb:cc:dd:ee:ff"], h.queue.task_ids
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cc:dd:ee:ff").action.last
  end

  test "queue_dhcp doesn't fail when mac address is blank but provided by compute resource" do
    cr = FactoryBot.build_stubbed(:libvirt_cr)
    cr.stubs(:provided_attributes).returns({:mac => :mac})
    host = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration, :compute_resource => cr)
    interface = host.interfaces.first
    interface.mac = nil
    interface.stubs(:dhcp? => true, :overwrite? => true)

    assert interface.send(:queue_dhcp)
  end

  test "new host should create a BMC dhcp reservation" do
    h = as_admin do
      FactoryBot.build(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:f1", :name => 'dummy-123')
    end
    assert h.new_record?
    h.interfaces_attributes = [{ :name => "dummy-bmc", :ip => h.ip.succ, :mac => "aa:bb:cd:cd:ee:ee",
                                 :subnet_id => h.subnet_id, :provider => 'IPMI', :type => 'Nic::BMC', :domain_id => h.domain_id}]
    assert h.valid?
    assert_equal ["dhcp_create_aa:bb:cc:dd:ee:f1", "dhcp_create_aa:bb:cd:cd:ee:ee"], h.queue.task_ids
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cc:dd:ee:f1").action.last
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cd:cd:ee:ee").action.last
  end

  test "when an existing host changes its ip address, its dhcp records should be updated" do
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:ff")
    end
    h.ip = h.ip.succ
    assert h.valid?
    assert_equal ["dhcp_remove_aa:bb:cc:dd:ee:ff", "dhcp_create_aa:bb:cc:dd:ee:ff"], h.queue.task_ids
    assert_equal :del_dhcp, h.queue.find_by_id("dhcp_remove_aa:bb:cc:dd:ee:ff").action.last
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cc:dd:ee:ff").action.last
  end

  test "when an existing host changes its PXE loader, its dhcp records should be updated" do
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:ff", :pxe_loader => "PXELinux BIOS")
    end
    h.pxe_loader = "PXELinux UEFI"
    assert h.valid?
    assert_equal ["dhcp_remove_aa:bb:cc:dd:ee:ff", "dhcp_create_aa:bb:cc:dd:ee:ff"], h.queue.task_ids
    assert_equal :del_dhcp, h.queue.find_by_id("dhcp_remove_aa:bb:cc:dd:ee:ff").action.last
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_aa:bb:cc:dd:ee:ff").action.last
  end

  test "when an existing host change its bmc ip address, its dhcp records should be updated" do
    h = nil
    as_admin do
      h = FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:ff")
      Nic::BMC.create!(:host_id => h.id, :mac => "da:aa:aa:ab:db:bb", :domain_id => h.domain_id,
                       :ip => h.ip.succ, :subnet_id => h.subnet_id, :name => "bmc-#{h}", :provider => 'IPMI')
    end
    h.reload
    bmc = h.interfaces.bmc.first
    old_ip = bmc.ip
    new_ip = bmc.ip = bmc.ip.succ
    assert bmc.valid?
    assert_equal ["dhcp_remove_da:aa:aa:ab:db:bb", "dhcp_create_da:aa:aa:ab:db:bb", "dhcp_create_aa:bb:cc:dd:ee:ff"], h.queue.task_ids
    assert_equal :del_dhcp, h.queue.find_by_id("dhcp_remove_da:aa:aa:ab:db:bb").action.last
    assert_equal old_ip, h.queue.find_by_id("dhcp_remove_da:aa:aa:ab:db:bb").action.first.ip
    assert_equal :set_dhcp, h.queue.find_by_id("dhcp_create_da:aa:aa:ab:db:bb").action.last
    assert_equal new_ip, h.queue.find_by_id("dhcp_create_da:aa:aa:ab:db:bb").action.first.ip
  end

  test "when an existing host changes its mac address, its dhcp records should be updated" do
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:f1")
    end
    h.mac = next_mac(h.mac)
    assert h.valid?
    # order is wrong due to priorities (5, 9, 10) - create should be processed first, then update
    assert_equal ["dhcp_remove_aa:bb:cc:dd:ee:f1", "dhcp_create_aa:bb:cc:dd:ee:f2", "dhcp_create_aa:bb:cc:dd:ee:f1"], h.queue.task_ids
  end

  test "when an existing host triggers a 'rebuild', its dhcp records should be updated if no dhcp records are found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(false)
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:f1")
    end

    h.build = true
    assert h.valid?, h.errors.messages.to_s
    assert_equal ["dhcp_remove_aa:bb:cc:dd:ee:f1", "dhcp_create_aa:bb:cc:dd:ee:f1"], h.queue.task_ids
  end

  test "when an existing host trigger a 'rebuild', its dhcp records should not be updated if valid dhcp records are found" do
    Net::DHCP::Record.any_instance.stubs(:valid?).returns(true)
    h = as_admin do
      FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:f1")
    end

    h.build = true
    assert h.valid?
    assert h.errors.empty?
    assert_equal ["dhcp_create_aa:bb:cc:dd:ee:f1"], h.queue.task_ids
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = nil
    as_admin do
      h = FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:bb:cc:dd:ee:f1")
      Nic::BMC.create! :host => h, :mac => "aa:aa:aa:ab:bd:bb", :ip => h.ip.succ, :domain => h.domain,
                       :subnet => h.subnet, :name => "bmc1-#{h}", :provider => 'IPMI'
    end
    h = Host.find(h.id)
    bmc = h.interfaces.bmc.first
    bmc.mac = next_mac(bmc.mac)
    assert h.valid?
    assert bmc.valid?
    assert_equal ["dhcp_remove_aa:aa:aa:ab:bd:bb", "dhcp_create_aa:aa:aa:ab:bd:bc"], h.queue.task_ids
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = nil
    as_admin do
      h = FactoryBot.create(:host, :with_dhcp_orchestration, :mac => "aa:aa:ad:ab:bb:cc")
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
    assert_equal 2, h.queue.items.count { |x| x.action == [h.primary_interface, :set_dhcp] }
    assert_equal 1, h.queue.items.count { |x| x.action.last == :del_dhcp }
    assert_equal 1, bmc.queue.items.count { |x| x.action == [bmc, :set_dhcp] }
    assert_equal 1, bmc.queue.items.count { |x| x.action == [bmc.old, :del_dhcp] }
  end

  test "new host with dhcp and no operating system should show correct validation on save" do
    h = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration, :operatingsystem => nil)

    # If there was an exception due to accessing operating_system.boot_filename when operating_system is nil
    # this line would cause an error in the test
    refute h.valid?
    assert_equal h.errors[:operatingsystem_id].first, "can't be blank"
  end

  test "should rebuild dhcp" do
    h = FactoryBot.create(:host, :with_dhcp_orchestration)
    Nic::Managed.any_instance.expects(:del_dhcp)
    Nic::Managed.any_instance.expects(:set_dhcp).returns(true)
    assert h.interfaces.first.rebuild_dhcp
  end

  test "should skip dhcp rebuild" do
    nic = FactoryBot.build_stubbed(:nic_managed)
    nic.expects(:set_dhcp).never
    assert nic.rebuild_dhcp
  end

  test "should fail with exception" do
    h = FactoryBot.create(:host, :with_dhcp_orchestration)
    Nic::Managed.any_instance.expects(:del_dhcp)
    Nic::Managed.any_instance.expects(:set_dhcp).raises(StandardError, 'DHCP test failure')
    refute h.interfaces.first.rebuild_dhcp
  end

  test "dhcp_records should return nil for invalid mac" do
    host = FactoryBot.build_stubbed(:host, :with_dhcp_orchestration, :interfaces => [FactoryBot.build_stubbed(:nic_primary_and_provision, :mac => "aaaaaa")])
    assert_nil host.dhcp_records.first
  end

  context '#boot_server' do
    let(:host) { FactoryBot.build_stubbed(:host, :managed, :with_tftp_orchestration) }
    let(:nic) { host.provision_interface }

    test 'should use boot server provided by proxy' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
      assert_equal '127.13.0.1', nic.send(:boot_server)
      assert_empty nic.errors
    end

    test 'should use boot server based on proxy url' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns(nil)
      assert_equal URI.parse(host.subnet.tftp.url).host, nic.send(:boot_server)
      assert_empty nic.errors
    end

    test 'should error out on no capabilities' do
      Foreman::Deprecation.expects(:deprecation_warning).once
      SmartProxy.any_instance.expects(:capabilities).with(:DHCP).returns([])
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('proxy.example.com')
      Resolv::DNS.any_instance.expects(:getaddress).once.returns("127.12.0.1")
      assert_equal '127.12.0.1', nic.send(:boot_server)
      assert_empty nic.errors
    end
  end
end
