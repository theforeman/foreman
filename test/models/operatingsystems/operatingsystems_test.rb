require 'test_helper'

class OperatingsystemsTest < ActiveSupport::TestCase
  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'expected' => 'CoreOS 494.5.0' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'Debian 7.0' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'Ubuntu 14.10' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'OpenSuse 11.4' } }.
  each do |os, config|
    test "os label for #{os}" do
      stub_os = FactoryBot.build_stubbed(config['os'],
                                  :architectures => [architectures((config['arch']))],
                                  :ptables => [FactoryBot.create(:ptable)],
                                  :media => [FactoryBot.build_stubbed(:medium)])
      assert_equal(config['expected'], stub_os.to_label)
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'expected' => '$arch/$version' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'boot/$arch/loader' } }.
  each do |os, config|
    test "pxedir  for #{os}" do
      stub_os = FactoryBot.build_stubbed(config['os'],
                             :architectures => [architectures((config['arch']))],
                             :ptables => [FactoryBot.create(:ptable)],
                             :media => [FactoryBot.build_stubbed(:medium)])

      assert_equal(config['expected'], stub_os.pxedir)
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/CoreOS-494.5.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62-coreos_production_pxe.vmlinuz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62-linux' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64-d7fdf2554cca70ac1a710b4a75127bf7fcb9dad8-linux' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse,   'expected' => 'boot/OpenSuse-11.4-x86_64-a60c87650b8a37ecb9e71348c355c5032abdac89-linux' } }.
  each do |os, config|
    test "kernel location for #{config['arch']} #{os}" do
      arch = architectures(config['arch'])
      host = FactoryBot.build_stubbed(:host,
                               :operatingsystem => FactoryBot.build_stubbed(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryBot.create(:ptable)],
                                                                     :media => [media(config['medium'])]),
                               :architecture => arch,
                               :medium => media(config['medium']))
      assert_equal(config['expected'], host.operatingsystem.kernel(host.arch, host))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/CoreOS-494.5.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62-coreos_production_pxe_image.cpio.gz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62-initrd.gz' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64-d7fdf2554cca70ac1a710b4a75127bf7fcb9dad8-initrd.gz' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse,   'expected' => 'boot/OpenSuse-11.4-x86_64-a60c87650b8a37ecb9e71348c355c5032abdac89-initrd' } }.
  each do |os, config|
    test "initrd location for #{config['arch']} #{os}" do
      arch = architectures(config['arch'])
      host = FactoryBot.build_stubbed(:host,
                               :operatingsystem => FactoryBot.build_stubbed(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryBot.create(:ptable)],
                                                                     :media => [media(config['medium'])]),
                               :architecture => arch,
                               :medium => media(config['medium']))
      assert_equal(config['expected'], host.operatingsystem.initrd(host.arch, host))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/CoreOS-494.5.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62'},
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64-c440a52e0119b57fc9109aeb7c4a19f5e8e75c62'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64-d7fdf2554cca70ac1a710b4a75127bf7fcb9dad8'},
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse,   'expected' => 'boot/OpenSuse-11.4-x86_64-a60c87650b8a37ecb9e71348c355c5032abdac89' } }.
  each do |os, config|
    test "pxe prefix for #{os}" do
      arch = architectures(config['arch'])
      host = FactoryBot.build_stubbed(:host,
                               :operatingsystem => FactoryBot.build_stubbed(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryBot.create(:ptable)],
                                                                     :media => [media(config['medium'])]),
                               :architecture => arch,
                               :medium => media(config['medium']))
      assert_equal(config['expected'], host.operatingsystem.pxe_prefix(host.arch, host))
    end
  end

  { :coreos => { 'os' => :coreos, 'arch' => :x86_64, 'medium' => :coreos,
                      'kernel' => 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz',
                      'initrd' => 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz'},
    :debian7_0   => { 'os' => :debian7_0, 'arch' => :x86_64, 'medium' => :debian,
                      'kernel' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux',
                      'initrd' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu,
                      'kernel' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux',
                      'initrd' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz'},
    :suse        => { 'os' => :suse, 'arch' => :x86_64, 'medium' => :suse,
                      'kernel' => 'http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/linux',
                      'initrd' => 'http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/initrd' } }.
  each do |os, config|
    test "pxe files for  #{os}" do
      medium = FactoryBot.build(:medium, config['medium'])

      arch = architectures(config['arch'])
      operatingsystem = FactoryBot.build(config['os'],
                                          :architectures => [arch],
                                          :ptables => [FactoryBot.create(:ptable)],
                                          :media => [medium])
      host = FactoryBot.build(:host,
                               :operatingsystem => operatingsystem,
                               :architecture    => arch,
                               :medium          => medium)

      host.medium.operatingsystems << host.operatingsystem
      host.arch.operatingsystems << host.operatingsystem

      prefix = host.operatingsystem.pxe_prefix(host.arch, host).to_sym
      pxe_files = host.operatingsystem.pxe_files(host.medium, host.arch, host)

      assert pxe_files.include?({ prefix => config['kernel'] })
      assert pxe_files.include?({ prefix => config['initrd'] })
    end
  end
end
