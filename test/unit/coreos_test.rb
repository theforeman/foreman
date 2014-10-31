require 'test_helper'

class CoreosTest < ActiveSupport::TestCase

  test "os label for coreos" do
    assert_equal "CoreOS 494.5.0", operatingsystems(:coreos).to_label
  end

  test "pxedir for coreos" do
    host = FactoryGirl.create(:host, :operatingsystem => operatingsystems(:coreos),
                              :architecture => architectures(:x86_64))
    pxedir ='amd64-usr/' + [host.os.major, host.os.minor ].compact.join('.')
    assert_equal pxedir, host.os.pxedir
  end

  test "kernel location for 64bit coreos" do
    host = FactoryGirl.create(:host, :operatingsystem => operatingsystems(:coreos),
                              :architecture => architectures(:x86_64))
    assert_equal "boot/CoreOS-494.5.0-x86_64-coreos_production_pxe.vmlinuz", host.os.kernel(host.arch)
  end

  test "initrd location for 64bit coreos" do
    host = FactoryGirl.create(:host, :operatingsystem => operatingsystems(:coreos),
                              :architecture => architectures(:x86_64))
    assert_equal "boot/CoreOS-494.5.0-x86_64-coreos_production_pxe_image.cpio.gz", host.os.initrd(host.arch)
  end

  test "pxe prefix for coreos" do
    host = FactoryGirl.create(:host, :operatingsystem => operatingsystems(:coreos),
                              :architecture => architectures(:x86_64))
    prefix = host.os.pxe_prefix(host.arch)
    assert_equal "boot/CoreOS-494.5.0-x86_64", prefix
  end

  test "pxe files for coreos" do
    host = FactoryGirl.create(:host, :with_medium,
                              :operatingsystem => operatingsystems(:coreos),
                              :architecture => architectures(:x86_64),
                              :medium => media(:coreos) )
    host.medium.operatingsystems << host.os
    host.arch.operatingsystems << host.os

    prefix = host.os.pxe_prefix(host.arch).to_sym
    pxe_files = host.os.pxe_files(host.medium, host.arch)

    kernel = { prefix => "http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz"  }
    initrd = { prefix => "http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz" }
    assert pxe_files.include?(kernel)
    assert pxe_files.include?(initrd)
  end

end
