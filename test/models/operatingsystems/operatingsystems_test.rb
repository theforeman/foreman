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

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'expected' => '$arch-usr/$version' },
    :redhat      => { 'os' => :rhel7_5,     'arch' => :x86_64, 'expected' => 'images/pxeboot' },
    :redhat_ppc  => { 'os' => :rhel7_5,     'arch' => :ppc64, 'expected' => 'ppc/ppc64' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch' },
    :debian7_1   => { 'os' => :debian7_1,   'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'boot/$arch/loader' } }.
  each do |os, config|
    test "pxedir for #{os}" do
      arch = architectures(config['arch'])
      operatingsystem = FactoryBot.build_stubbed(config['os'],
        :architectures => [arch],
        :ptables => [FactoryBot.create(:ptable)],
        :media => [media(:unused)])
      host = FactoryBot.build_stubbed(:host,
        :operatingsystem => operatingsystem,
        :architecture => arch,
        :medium => media(:unused))
      medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)

      assert_equal(config['expected'], operatingsystem.pxedir(medium_provider))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-ZX7K5DrIw8GD-coreos_production_pxe.vmlinuz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-zk3iA1lqbWLp-linux' },
    :debian7_1   => { 'os' => :debian7_1,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-k1O72L6ktmiV-linux' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-nBGUKFMjrPYz-linux' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-51xY4YC2vskO-linux' } }.
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
      medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)

      assert_equal(config['expected'], host.operatingsystem.kernel(medium_provider))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-ZX7K5DrIw8GD-coreos_production_pxe_image.cpio.gz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-zk3iA1lqbWLp-initrd.gz' },
    :debian7_1   => { 'os' => :debian7_1,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-k1O72L6ktmiV-initrd.gz' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-nBGUKFMjrPYz-initrd.gz' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-51xY4YC2vskO-initrd' } }.
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

      medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)
      assert_equal(config['expected'], host.operatingsystem.initrd(medium_provider))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-ZX7K5DrIw8GD'},
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-zk3iA1lqbWLp'},
    :debian7_1   => { 'os' => :debian7_1,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-k1O72L6ktmiV'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-nBGUKFMjrPYz'},
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-51xY4YC2vskO' } }.
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
      medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)
      assert_equal(config['expected'], host.operatingsystem.pxe_prefix(medium_provider))
    end
  end

  dists = {
    :debian7_0 => {
      'os' => :debian7_0,
      'arch' => :x86_64,
      'medium' => :debian,
      'kernel' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux',
      'initrd' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz',
    },
    :ubuntu14_10 => {
      'os' => :ubuntu14_10,
      'arch' => :x86_64,
      'medium' => :ubuntu,
      'kernel' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux',
      'initrd' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz',
    },
    :suse => {
      'os' => :suse,
      'arch' => :x86_64,
      'medium' => :suse,
      'kernel' => 'http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/linux',
      'initrd' => 'http://mirror.isoc.org.il/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/initrd',
    },
    :coreos => {
      'os' => :coreos,
      'arch' => :x86_64,
      'medium' => :coreos,
      'kernel' => 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz',
      'initrd' => 'http://stable.release.core-os.net/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz',
    },
    :fcos => {
      'os' => :fcos,
      'arch' => :x86_64,
      'medium' => :fcos,
      'major' => '32',
      'minor' => '20200907.3.0',
      'release_name' => 'stable',
      'kernel' => 'http://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20200907.3.0/x86_64/fedora-coreos-32.20200907.3.0-live-kernel-x86_64',
      'initrd' => 'http://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20200907.3.0/x86_64/fedora-coreos-32.20200907.3.0-live-initramfs.x86_64.img',
    },
    :rhcos => {
      'os' => :rhcos,
      'arch' => :x86_64,
      'medium' => :rhcos,
      'major' => '4',
      'minor' => '5',
      'release_name' => '6',
      'kernel' => 'http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.5/4.5.6/rhcos-live-kernel-x86_64',
      'initrd' => 'http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.5/4.5.6/rhcos-live-initramfs.x86_64.img',
    },
  }
  dists.each do |os, config|
    test "pxe files for #{os}" do
      medium = FactoryBot.build(:medium, config['medium'])

      arch = architectures(config['arch'])
      operatingsystem = FactoryBot.build(config['os'],
        :architectures => [arch],
        :ptables => [FactoryBot.create(:ptable)],
        :media => [medium])
      operatingsystem.major = config['major'] if config['major']
      operatingsystem.minor = config['minor'] if config['minor']
      operatingsystem.release_name = config['release_name'] if config['release_name']
      host = FactoryBot.build(:host,
        :operatingsystem => operatingsystem,
        :architecture    => arch,
        :medium          => medium)

      host.medium.operatingsystems << host.operatingsystem
      host.arch.operatingsystems << host.operatingsystem
      medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)

      pxe_files = host.operatingsystem.pxe_files(medium_provider).map { |x| x.values }.flatten
      assert_includes pxe_files, config['kernel']
      assert_includes pxe_files, config['initrd']
    end
  end
end
