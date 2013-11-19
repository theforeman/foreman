require 'test_helper'

class SuseTest < ActiveSupport::TestCase

  test "ruby class should be OS" do
    assert_equal Operatingsystem, Suse.first.class
  end

  test "os label for suse" do
    assert_equal "OpenSuse 11.4", operatingsystems(:suse).to_label
  end

  test "pxedir for suse" do
   assert_equal "boot/$arch/loader", operatingsystems(:suse).pxedir
  end

  test "kernel location for 64bit arch suse" do
    system = systems(:suse)
    assert_equal "boot/OpenSuse-11.4-x86_64-linux", system.os.kernel(system.arch)
  end

  test "initrd location for 64bit arch suse" do
    system = systems(:suse)
    assert_equal "boot/OpenSuse-11.4-x86_64-initrd", system.os.initrd(system.arch)
  end

  test "pxe prefix for suse" do
    system = systems(:suse)
    prefix = system.os.pxe_prefix(system.arch)
    assert_equal "boot/OpenSuse-11.4-x86_64", prefix
  end

  test "pxe files for suse" do
    system = systems(:suse)
    system.medium.operatingsystems << system.os
    system.arch.operatingsystems << system.os

    prefix = system.os.pxe_prefix(system.arch).to_sym

    kernel = { prefix => "http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/linux"  }
    initrd = { prefix => "http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/initrd" }
    assert system.os.pxe_files(system.medium, system.arch).include?(kernel)
    assert system.os.pxe_files(system.medium, system.arch).include?(initrd)
  end

end
