require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  test "host_should_have_tftp" do
    if unattended?
      h = FactoryGirl.build(:host, :managed, :with_tftp_orchestration)
      assert h.tftp?
      assert_not_nil h.tftp
    end
  end

  test "host_should_not_have_tftp" do
    if unattended?
      h = FactoryGirl.create(:host)
      assert_equal false, h.tftp?
      assert_equal nil, h.tftp
    end
  end

  test "host_without_pxe_loader_should_not_have_tftp" do
    skip_without_unattended
    h = FactoryGirl.build(:host, :managed, :with_tftp_orchestration)
    h.expects(:pxe_loader).returns('').at_least(1)
    assert_equal false, h.tftp?
    assert_equal nil, h.tftp
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:provision?).never
      assert h.valid?
      assert_equal false, h.tftp?
    end
  end

  test "generate_pxe_template_for_pxelinux_build" do
    if unattended?
      h = FactoryGirl.build(:host, :managed, :build => true,
                            :operatingsystem => operatingsystems(:redhat),
                            :architecture => architectures(:x86_64))
      Setting[:unattended_url] = "http://ahost.com:3000"

      template = h.send(:generate_pxe_template, :PXELinux).to_s.gsub! '~', "\n"
      expected = <<-EXPECTED
default linux
label linux
kernel boot/Redhat-6.1-x86_64-vmlinuz
append initrd=boot/Redhat-6.1-x86_64-initrd.img ks=http://ahost.com:3000/unattended/kickstart ksdevice=bootif network kssendmac
EXPECTED
      assert_equal template,expected.strip
      assert h.build
    end
  end

  test "generate_pxe_template_for_pxelinux_localboot" do
    if unattended?
      h = FactoryGirl.create(:host, :managed)
      as_admin { h.update_attribute :operatingsystem, operatingsystems(:centos5_3) }
      assert !h.build

      template = h.send(:generate_pxe_template, :PXELinux).to_s.gsub! '~', "\n"
      expected = <<-EXPECTED
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
      assert_equal template,expected.strip
    end
  end

  test "should_rebuild_tftp" do
    h = FactoryGirl.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).returns(true)
    assert h.interfaces.first.rebuild_tftp
  end

  describe "validation" do
    setup do
      @host = FactoryGirl.create(:host, :with_tftp_orchestration)
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
    h = FactoryGirl.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).raises(StandardError, 'TFTP rebuild failed')
    refute h.interfaces.first.rebuild_tftp
  end

  test "should_skip_rebuild_tftp" do
    nic = FactoryGirl.build(:nic_managed)
    nic.expects(:setTFTP).never
    assert nic.rebuild_tftp
  end

  test "generate_pxelinux_template_for_suse_build" do
    if unattended?
      h = FactoryGirl.build(:host, :managed, :build => true,
                            :operatingsystem => operatingsystems(:opensuse),
                            :architecture => architectures(:x86_64))
      Setting[:unattended_url] = "http://ahost.com:3000"

      template = h.send(:generate_pxe_template, :PXELinux).to_s.gsub! '~', "\n"
      expected = <<-EXPECTED
DEFAULT linux
LABEL linux
KERNEL boot/OpenSuse-12.3-x86_64-linux
APPEND initrd=boot/OpenSuse-12.3-x86_64-initrd ramdisk_size=65536 install=http://download.opensuse.org/distribution/12.3/repo/oss autoyast=http://ahost.com:3000/unattended/provision textmode=1
EXPECTED
      assert_equal template,expected.strip
      assert h.build
    end
  end
end
