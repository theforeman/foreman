require 'test_helper'

class OperatingsystemsTest < ActiveSupport::TestCase
  def setup
    stub_request(:head, %r'http://www.example.com/.*(linux|cpio.gz|vmlinuz|initrd|initrd.img|initrd.gz)').to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
    stub_request(:head, %r'http://.*.release.core-os.net/.*(linux|cpio.gz|vmlinuz|initrd|initrd.img|initrd.gz)').to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
    stub_request(:head, %r'http://(ftp.debian.org|archive.ubuntu.com)/.*(linux|cpio.gz|vmlinuz|initrd|initrd.img|initrd.gz)').to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
    stub_request(:head, %r'http://mirror.isoc.org.il/.*(linux|cpio.gz|vmlinuz|initrd|initrd.img|initrd.gz)').to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
  end

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
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'expected' => 'dists/$release/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'expected' => 'boot/$arch/loader' } }.
  each do |os, config|
    test "pxedir for #{os}" do
      stub_os = FactoryBot.build_stubbed(config['os'],
                             :architectures => [architectures((config['arch']))],
                             :ptables => [FactoryBot.create(:ptable)],
                             :media => [FactoryBot.build_stubbed(:medium)])

      assert_equal(config['expected'], stub_os.pxedir)
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-gomKIDxxXGyr-coreos_production_pxe.vmlinuz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-22gSejCmiWvb-linux' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-MISc0aOlWLr3-linux' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-n8xNOWMpKlrW-linux' } }.
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
      medium_provider = Foreman::Plugin.medium_providers.find_provider(host)

      assert_equal(config['expected'], host.operatingsystem.kernel(medium_provider))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-gomKIDxxXGyr-coreos_production_pxe_image.cpio.gz' },
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-22gSejCmiWvb-initrd.gz' },
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-MISc0aOlWLr3-initrd.gz' },
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-n8xNOWMpKlrW-initrd' } }.
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

      medium_provider = Foreman::Plugin.medium_providers.find_provider(host)
      assert_equal(config['expected'], host.operatingsystem.initrd(medium_provider))
    end
  end

  { :coreos      => { 'os' => :coreos,      'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-gomKIDxxXGyr'},
    :debian7_0   => { 'os' => :debian7_0,   'arch' => :x86_64, 'medium' => :unused, 'expected' => 'boot/unused-22gSejCmiWvb'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu, 'expected' => 'boot/ubuntu-mirror-MISc0aOlWLr3'},
    :suse        => { 'os' => :suse,        'arch' => :x86_64, 'medium' => :opensuse, 'expected' => 'boot/opensuse-n8xNOWMpKlrW' } }.
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
      medium_provider = Foreman::Plugin.medium_providers.find_provider(host)
      assert_equal(config['expected'], host.operatingsystem.pxe_prefix(medium_provider))
    end
  end

  { :coreos => { 'os' => :coreos, 'arch' => :x86_64, 'medium' => :coreos,
                      'kernel' => 'http://www.example.com/amd64-usr/494.5.0/coreos_production_pxe.vmlinuz',
                      'initrd' => 'http://www.example.com/amd64-usr/494.5.0/coreos_production_pxe_image.cpio.gz'},
    :debian7_0   => { 'os' => :debian7_0, 'arch' => :x86_64, 'medium' => :debian,
                      'kernel' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux',
                      'initrd' => 'http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz'},
    :ubuntu14_10 => { 'os' => :ubuntu14_10, 'arch' => :x86_64, 'medium' => :ubuntu,
                      'kernel' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux',
                      'initrd' => 'http://archive.ubuntu.com/ubuntu/dists/utopic/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz'},
    :suse        => { 'os' => :suse, 'arch' => :x86_64, 'medium' => :suse,
                      'kernel' => 'http://download.opensuse.org/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/linux',
                      'initrd' => 'http://download.opensuse.org/pub/opensuse/distribution/11.4/repo/oss/boot/x86_64/loader/initrd' } }.
  each do |os, config|
    test "pxe files for #{os}" do
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

      pxe_files = host.pxe_files
      assert_equal config['kernel'], pxe_files.first.values.first
      assert_equal config['initrd'], pxe_files.second.values.first
    end
  end
end
