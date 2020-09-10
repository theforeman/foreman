require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  context 'host without tftp orchestration' do
    setup do
      @host = FactoryBot.create(:host)
    end

    test 'should not have any tftp' do
      skip_without_unattended
      assert_equal false, @host.tftp?
      assert_equal false, @host.tftp6?
      assert_nil @host.tftp
      assert_nil @host.tftp6
    end

    test '#setTFTP should not call any tftp proxy' do
      ProxyAPI::TFTP.any_instance.expects(:set).never
      @host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      @host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end

    test 'should not queue tftp' do
      @host.provision_interface.send(:queue_tftp)
      tasks = @host.queue.all.map { |t| t.name }
      assert_empty tasks
    end
  end

  context 'host with ipv4 tftp' do
    setup do
      @host = FactoryBot.build_stubbed(:host, :managed, :with_tftp_orchestration, :build => true)
    end

    test 'should have tftp' do
      skip_without_unattended
      assert @host.tftp?
      refute @host.tftp6?
      assert_not_nil @host.tftp
      assert_nil @host.tftp6
    end

    test '#setTFTP should call one tftp proxy' do
      ProxyAPI::TFTP.any_instance.expects(:set).once
      @host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      @host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end

    test 'should queue tftp' do
      @host.provision_interface.send(:queue_tftp)
      tasks = @host.queue.all.map { |t| t.name }
      assert_includes tasks, "Deploy TFTP PXEGrub config for #{@host.provision_interface}"
      assert_includes tasks, "Fetch TFTP boot files for #{@host.provision_interface}"
    end

    test "without pxe loader should not have tftp" do
      skip_without_unattended
      @host.expects(:pxe_loader).returns('').at_least(1)
      assert_equal false, @host.tftp?
      assert_nil @host.tftp
    end
  end

  context 'host with ipv6 tftp' do
    setup do
      @host = FactoryBot.build_stubbed(:host, :managed, :with_tftp_v6_orchestration, :build => true)
    end

    test "should have ipv6 tftp" do
      skip_without_unattended
      refute @host.tftp?
      assert @host.tftp6?
      assert_nil @host.tftp
      assert_not_nil @host.tftp6
      assert_nil @host.subnet
    end

    test '#setTFTP should call one tftp proxy' do
      ProxyAPI::TFTP.any_instance.expects(:set).once
      @host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      @host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end

    test 'should queue tftp' do
      @host.provision_interface.send(:queue_tftp)
      tasks = @host.queue.all.map { |t| t.name }
      assert_includes tasks, "Deploy TFTP PXEGrub config for #{@host.provision_interface}"
      assert_includes tasks, "Fetch TFTP boot files for #{@host.provision_interface}"
    end
  end

  context 'host with ipv4 and ipv6 tftp' do
    setup do
      @host = FactoryBot.build_stubbed(:host, :managed, :with_tftp_dual_stack_orchestration, :build => true)
    end

    test "host should have ipv4 and ipv6 tftp" do
      skip_without_unattended
      assert @host.tftp?
      assert @host.tftp6?
      assert_not_nil @host.tftp
      assert_not_nil @host.tftp6
    end

    test '#setTFTP should call both tftp proxies' do
      ProxyAPI::TFTP.any_instance.expects(:set).twice
      @host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      @host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end

    test '#setTFTP should call just one proxy if the proxies are unique' do
      ProxyAPI::TFTP.any_instance.expects(:set).once
      @host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      @host.provision_interface.subnet6.tftp = @host.provision_interface.subnet.tftp
      assert @host.provision_interface.subnet6.save!
      @host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end

    test 'should queue tftp' do
      @host.provision_interface.send(:queue_tftp)
      tasks = @host.queue.all.map { |t| t.name }
      assert_includes tasks, "Deploy TFTP PXEGrub config for #{@host.provision_interface}"
      assert_includes tasks, "Fetch TFTP boot files for #{@host.provision_interface}"
    end
  end

  context 'host with bond interface' do
    let(:subnet) do
      FactoryBot.build(:subnet_ipv4, :tftp, :with_taxonomies)
    end
    let(:interfaces) do
      [
        FactoryBot.build(:nic_bond, :primary => true,
                          :identifier => 'bond0',
                          :attached_devices => ['eth0', 'eth1'],
                          :provision => true,
                          :domain => FactoryBot.build_stubbed(:domain),
                          :subnet => subnet,
                          :mac => nil,
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
      FactoryBot.create(:host,
        :with_tftp_orchestration,
        :subnet => subnet,
        :interfaces => interfaces,
        :build => true,
        :location => subnet.locations.first,
        :organization => subnet.organizations.first)
    end

    test '#setTFTP should provision tftp for all bond child macs' do
      ProxyAPI::TFTP.any_instance.expects(:set).with(
        'PXEGrub2',
        '00:53:67:ab:dd:00',
        {:pxeconfig => 'Template'}
      ).once
      ProxyAPI::TFTP.any_instance.expects(:set).with(
        'PXEGrub2',
        '00:53:67:ab:dd:01',
        {:pxeconfig => 'Template'}
      ).once
      host.provision_interface.stubs(:generate_pxe_template).returns('Template')
      host.provision_interface.send(:setTFTP, 'PXEGrub2')
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryBot.create(:host)
      Nic::Managed.any_instance.expects(:provision?).never
      assert h.valid?
      assert_equal false, h.tftp?
    end
  end

  test "generate_pxe_template_for_pxelinux_build" do
    return unless unattended?
    h = FactoryBot.build_stubbed(:host, :managed, :build => true,
                          :operatingsystem => operatingsystems(:redhat),
                          :architecture => architectures(:x86_64))
    h.organization.update_attribute :ignore_types, h.organization.ignore_types + ['ProvisioningTemplate']
    h.location.update_attribute :ignore_types, h.location.ignore_types + ['ProvisioningTemplate']
    Setting[:unattended_url] = "http://ahost.com:3000"

    template = h.send(:generate_pxe_template, :PXELinux).to_s.tr! '~', "\n"
    expected = <<~EXPECTED
      default linux
      label linux
      kernel boot/centos-5-4-uWCeq9vTUar3-vmlinuz
      append initrd=boot/centos-5-4-uWCeq9vTUar3-initrd.img ks=http://ahost.com:3000/unattended/kickstart ksdevice=bootif network kssendmac
    EXPECTED
    assert_equal expected.strip, template
    assert h.build
  end

  test "generate_pxe_template_for_pxelinux_localboot" do
    return unless unattended?
    h = FactoryBot.create(:host, :managed)
    as_admin do
      os = operatingsystems(:centos5_3)
      os.media << h.medium
      os.architectures << h.architecture
      h.update_attribute :operatingsystem, os
    end
    assert !h.build

    template = h.send(:generate_pxe_template, :PXELinux).to_s.tr! '~', "\n"
    expected = <<~EXPECTED
      DEFAULT menu
      PROMPT 0
      MENU TITLE PXE Menu
      TIMEOUT 200
      TOTALTIMEOUT 6000
      ONTIMEOUT local

      LABEL local
      MENU LABEL (local)
      MENU DEFAULT
      LOCALBOOT 0
    EXPECTED
    assert_equal template, expected.strip
  end

  test "generate_default_pxe_template_for_pxelinux_localboot_from_setting" do
    return unless unattended?
    template = FactoryBot.create(:provisioning_template, :name => 'my template',
                                                          :template => 'test content',
                                                          :template_kind => template_kinds(:pxelinux))
    Setting['local_boot_PXELinux'] = template.name
    h = FactoryBot.create(:host, :managed)
    as_admin do
      os = operatingsystems(:centos5_3)
      os.media << h.medium
      os.architectures << h.architecture
      h.update_attribute :operatingsystem, os
    end
    assert !h.build

    result = h.send(:generate_pxe_template, :PXELinux)
    assert_equal template.template, result
  end

  test "generate_default_pxe_template_for_pxelinux_localboot_from_param" do
    return unless unattended?
    template = FactoryBot.create(:provisioning_template, :name => 'my template',
                                                          :template => 'test content again',
                                                          :template_kind => template_kinds(:pxelinux))
    h = FactoryBot.create(:host, :managed)
    FactoryBot.create(:host_parameter, :name => 'local_boot_PXELinux', :value => template.name, :reference_id => h.id)
    as_admin do
      os = operatingsystems(:centos5_3)
      os.media << h.medium
      os.architectures << h.architecture
      h.update_attribute :operatingsystem, os
    end
    assert !h.build

    result = h.send(:generate_pxe_template, :PXELinux)
    assert_equal template.template, result
  end

  test 'omit trying to generate a template for non-existing localboot template' do
    return unless unattended?
    h = FactoryBot.create(:host, :managed)
    as_admin do
      os = operatingsystems(:vrp5)
      os.media << h.medium
      os.architectures << h.architecture
      h.update_attribute :operatingsystem, os
    end
    assert !h.build

    result = h.send(:generate_pxe_template, :ZTP)
    assert result.blank?
    assert h.errors.empty?
  end

  test 'should rebuild tftp IPv4' do
    host = FactoryBot.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXELinux').once.returns(true)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub').once.returns(true)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub2').once.returns(true)
    assert host.interfaces.first.rebuild_tftp
  end

  test 'should rebuild tftp IPv6' do
    host = FactoryBot.create(:host, :with_tftp_v6_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXELinux').once.returns(true)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub').once.returns(true)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub2').once.returns(true)
    assert host.interfaces.first.rebuild_tftp
  end

  describe "validation" do
    setup do
      @host = FactoryBot.create(:host, :with_tftp_orchestration)
      @host.stubs(:provisioning_template).returns(nil)
      @host.pxe_loader = nil
    end

    test "should not fail without PXE loader" do
      skip_without_unattended
      @host.interfaces.first.send(:validate_tftp)
      assert_nil @host.errors[:base].first
    end

    test "should not fail with None PXE loader" do
      skip_without_unattended
      @host.pxe_loader = ""
      @host.interfaces.first.send(:validate_tftp)
      assert_nil @host.errors[:base].first
    end

    test "should fail without PXEGrub2 kind" do
      skip_without_unattended
      @host.pxe_loader = "grub2/grubx64.efi"
      @host.interfaces.first.send(:validate_tftp)
      assert_match /^No PXEGrub2 templates were found.*/, @host.errors[:base].first
    end

    test "should fail without PXEGrub kind" do
      skip_without_unattended
      @host.pxe_loader = "grub/bootx64.efi"
      @host.interfaces.first.send(:validate_tftp)
      assert_match /^No PXEGrub templates were found.*/, @host.errors[:base].first
    end

    test "should fail without PXELinux kind" do
      skip_without_unattended
      @host.pxe_loader = "pxelinux.0"
      @host.interfaces.first.send(:validate_tftp)
      assert_match /^No PXELinux templates were found.*/, @host.errors[:base].first
    end
  end

  test "should_fail_rebuild_tftp_with_exception" do
    h = FactoryBot.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXELinux').raises(StandardError, 'TFTP rebuild failed')
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub').once.returns(true)
    Nic::Managed.any_instance.expects(:setTFTP).with('PXEGrub2').once.returns(true)
    refute h.interfaces.first.rebuild_tftp
  end

  test "should_skip_rebuild_tftp" do
    nic = FactoryBot.build_stubbed(:nic_managed)
    nic.expects(:setTFTP).never
    assert nic.rebuild_tftp
  end

  test "generate_pxelinux_template_for_suse_build" do
    return unless unattended?
    h = FactoryBot.build_stubbed(:host, :managed, :build => true,
                          :operatingsystem => operatingsystems(:opensuse),
                          :architecture => architectures(:x86_64))
    Setting[:unattended_url] = "http://ahost.com:3000"
    h.organization.update_attribute :ignore_types, h.organization.ignore_types + ['ProvisioningTemplate']
    h.location.update_attribute :ignore_types, h.location.ignore_types + ['ProvisioningTemplate']

    template = h.send(:generate_pxe_template, :PXELinux).to_s.tr! '~', "\n"
    expected = <<~EXPECTED
      DEFAULT linux
      LABEL linux
      KERNEL boot/opensuse-Ek8x7Rr7itxO-linux
      APPEND initrd=boot/opensuse-Ek8x7Rr7itxO-initrd ramdisk_size=65536 install=http://download.opensuse.org/distribution/12.3/repo/oss autoyast=http://ahost.com:3000/unattended/provision textmode=1
    EXPECTED
    assert_equal expected.strip, template
    assert h.build
  end
end
