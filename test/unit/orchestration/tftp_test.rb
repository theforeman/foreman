require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  def test_host_should_have_tftp
    if unattended?
      h = FactoryGirl.build(:host, :managed, :with_tftp_orchestration)
      assert h.tftp?
      assert_not_nil h.tftp
    end
  end

  def test_host_should_not_have_tftp
    if unattended?
      h = FactoryGirl.create(:host)
      assert_equal false, h.tftp?
      assert_equal nil, h.tftp
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:provision?).never
      assert h.valid?
      assert_equal false, h.tftp?
    end
  end

  def test_generate_pxe_template_for_build
    if unattended?
      h = FactoryGirl.build(:host, :managed, :build => true,
                            :operatingsystem => operatingsystems(:redhat),
                            :architecture => architectures(:x86_64))
      Setting[:unattended_url] = "http://ahost.com:3000"

      template = h.send(:generate_pxe_template).to_s.gsub! '~', "\n"
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

  def test_generate_pxe_template_for_localboot
    if unattended?
      h = FactoryGirl.create(:host, :managed)
      as_admin { h.update_attribute :operatingsystem, operatingsystems(:centos5_3) }
      assert !h.build

      template = h.send(:generate_pxe_template).to_s.gsub! '~', "\n"
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

  def test_should_rebuild_tftp
    h = FactoryGirl.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).returns(true)
    assert h.interfaces.first.rebuild_tftp
  end

  def test_should_fail_rebuilding_when_template_is_missing
    h = FactoryGirl.create(:host, :with_tftp_orchestration)
    as_admin { h.update_attribute :operatingsystem, operatingsystems(:centos5_3) }
    h.build = true
    h.stubs(:provisioning_template).returns(nil)
    refute h.interfaces.first.rebuild_tftp
    assert_match /No PXELinux templates were found/, h.errors[:base].first
  end

  def test_should_fail_rebuild_tftp_with_exception
    h = FactoryGirl.create(:host, :with_tftp_orchestration)
    Nic::Managed.any_instance.expects(:setTFTP).raises(StandardError, 'TFTP rebuild failed')
    refute h.interfaces.first.rebuild_tftp
  end

  def test_should_skip_rebuild_tftp
    nic = FactoryGirl.build(:nic_managed)
    nic.expects(:setTFTP).never
    assert nic.rebuild_tftp
  end

  def test_generate_pxe_template_for_suse_build
    if unattended?
      h = FactoryGirl.build(:host, :managed, :build => true,
                            :operatingsystem => operatingsystems(:opensuse),
                            :architecture => architectures(:x86_64))
      Setting[:unattended_url] = "http://ahost.com:3000"

      template = h.send(:generate_pxe_template).to_s.gsub! '~', "\n"
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
