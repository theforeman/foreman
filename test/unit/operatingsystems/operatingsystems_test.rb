require 'test_helper'

class OperatingsystemsTest < ActiveSupport::TestCase
  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'expected' => 'CoreOS 494.5.0' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'Debian 7.0' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'Ubuntu 14.10' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'OpenSuse 11.4' } }.
  each do |os, config|
    test "os label for #{os}" do
      stub_os = FactoryGirl.build(config['os'],
                                  :architectures => [architectures((config['arch']))],
                                  :ptables => [FactoryGirl.create(:ptable)],
                                  :media => [FactoryGirl.build(:medium)])
      assert_equal(config['expected'], stub_os.to_label)
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'expected' => '$arch/$version' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'boot/$arch/loader' } }.
  each do |os, config|
    test "pxedir  for #{os}" do
      stub_os = FactoryGirl.build(config['os'],
                             :architectures => [architectures((config['arch']))],
                             :ptables => [FactoryGirl.create(:ptable)],
                             :media => [FactoryGirl.build(:medium)])

      assert_equal(config['expected'], stub_os.pxedir)
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :coreos, 'expected' => 'boot/CoreOS-494.5.0-x86_64-coreos_production_pxe.vmlinuz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64-linux' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64-linux' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :suse,   'expected' => 'boot/OpenSuse-11.4-x86_64-linux' } }.
  each do |os, config|
    test "kernel location for #{config['arch']} #{os}" do
      arch = architectures(config['arch'])
      host = FactoryGirl.build(:host,
                               :operatingsystem => FactoryGirl.build(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryGirl.create(:ptable)],
                                                                     :media => [FactoryGirl.build(:medium)]),
                               :architecture => arch)
      assert_equal(config['expected'], host.operatingsystem.kernel(host.arch))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :coreos, 'expected' => 'boot/CoreOS-494.5.0-x86_64-coreos_production_pxe_image.cpio.gz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64-initrd.gz' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64-initrd.gz' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :suse,   'expected' => 'boot/OpenSuse-11.4-x86_64-initrd' } }.
  each do |os, config|
    test "initrd location for #{config['arch']} #{os}" do
      arch = architectures(config['arch'])
      host = FactoryGirl.build(:host,
                               :operatingsystem => FactoryGirl.build(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryGirl.create(:ptable)],
                                                                     :media => [FactoryGirl.build(:medium)]),
                               :architecture => arch)
      assert_equal(config['expected'], host.operatingsystem.initrd(host.arch))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :coreos, 'expected' => 'boot/CoreOS-494.5.0-x86_64'},
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/Debian-7.0-x86_64'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/Ubuntu-14.10-x86_64'},
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :suse,   'expected' => 'boot/OpenSuse-11.4-x86_64' } }.
  each do |os, config|
    test "pxe prefix for #{os}" do
      arch = architectures(config['arch'])
      host = FactoryGirl.build(:host,
                               :operatingsystem => FactoryGirl.build(config['os'],
                                                                     :architectures => [arch],
                                                                     :ptables => [FactoryGirl.create(:ptable)],
                                                                     :media => [FactoryGirl.build(:medium)]),
                               :architecture => arch)
      assert_equal(config['expected'], host.operatingsystem.pxe_prefix(host.arch))
    end
  end

  { :coreos      => { 'os' => :coreos, 'arch' => :x86_64, 'medium' => :coreos,
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
      medium = FactoryGirl.build(:medium, config['medium'])
      Medium.connection.execute("DELETE from media_operatingsystems")
      Medium.where(:name => medium.name).delete_all

      arch = architectures(config['arch'])
      operatingsystem = FactoryGirl.build(config['os'],
                                          :architectures => [arch],
                                          :ptables => [FactoryGirl.create(:ptable)],
                                          :media => [medium])
      host = FactoryGirl.build(:host,
                               :operatingsystem => operatingsystem,
                               :architecture    => arch,
                               :medium          => medium)

      host.medium.operatingsystems << host.operatingsystem
      host.arch.operatingsystems << host.operatingsystem

      prefix = host.operatingsystem.pxe_prefix(host.arch).to_sym
      pxe_files = host.operatingsystem.pxe_files(host.medium, host.arch)

      assert pxe_files.include?({ prefix => config['kernel'] })
      assert pxe_files.include?({ prefix => config['initrd'] })
    end
  end
end
