require 'test_helper'

class Foreman::BootloaderUniverse::HostBootFilesTest < ActiveSupport::TestCase
  setup do
    @architecture = Architecture.new(name: 'x86_64')
    @os = Redhat.new(name: 'CentOS', major: '10')
    @proxy = mock('tftp proxy')
    @proxy.stubs(:has_feature?).with('TFTP').returns(true)
    @proxy.stubs(:has_capability?).returns(true)
    @interface = mock('provision interface')
    @proxy.stubs(:url).returns('https://proxy.example.test')
    @subnet = mock('subnet')
    @subnet.stubs(:tftp).returns(@proxy)
    @interface.stubs(tftp?: true, tftp6?: false, subnet: @subnet)
    @provider = mock('medium provider')
    @provider.stubs(:boot_file_source_uri).returns('https://mirror.example.test/centos/10')
    @host = mock('host')
    @host.stubs(build?: true, pxe_loader_efi?: true, pxe_loader: 'Grub2 UEFI',
      operatingsystem: @os, arch: @architecture, provision_interface: @interface,
      medium_provider: @provider)
    @host.stubs(:host_param).with('disable_universe').returns(nil)
  end

  test 'uses the Red Hat boot ISO as the source for universe kernel and initramdisk' do
    plan = Foreman::BootloaderUniverse::HostBootFiles.new(@host).call

    directory = 'bootloader-universe/pxegrub2/centos/10/x86_64'
    assert_equal "#{directory}/vmlinuz", plan[:kernel]
    assert_equal "#{directory}/initrd.img", plan[:initrd]
    assert_equal "#{directory}/boot.iso", plan[:archive]
    assert_equal Digest::SHA256.hexdigest('https://mirror.example.test/centos/10/images/boot.iso'), plan[:source_digest]
  end

  test 'uses the Debian netboot archive for universe kernel and initramdisk' do
    @os = Debian.new(name: 'Debian', major: '12', release_name: 'bookworm')
    @host.stubs(:pxe_loader).returns('Grub2 UEFI SecureBoot')
    @host.stubs(:operatingsystem).returns(@os)
    plan = Foreman::BootloaderUniverse::HostBootFiles.new(@host).call

    directory = 'bootloader-universe/pxegrub2/debian/12/x86_64'
    assert_equal "#{directory}/linux", plan[:kernel]
    assert_equal "#{directory}/initrd.gz", plan[:initrd]
    assert_equal "#{directory}/netboot.tar.gz", plan[:archive]
    assert_equal Digest::SHA256.hexdigest('https://mirror.example.test/centos/10/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz'), plan[:source_digest]
  end

  test 'uses the Ubuntu netboot archive rather than its separate ISO' do
    @os = Debian.new(name: 'Ubuntu', major: '26', minor: '04', release_name: 'resolute')
    @host.stubs(:operatingsystem).returns(@os)
    plan = Foreman::BootloaderUniverse::HostBootFiles.new(@host).call

    assert_equal 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/netboot.tar.gz', plan[:archive]
    assert_equal Digest::SHA256.hexdigest('https://mirror.example.test/centos/10/26.04/ubuntu-26.04-netboot-amd64.tar.gz'), plan[:source_digest]
    assert_equal 'https://mirror.example.test/centos/10/26.04/ubuntu-26.04-live-server-amd64.iso', plan[:installation_iso]
  end

  test 'keeps legacy downloads when a proxy lacks host boot file validation' do
    @proxy.stubs(:has_capability?).with(:TFTP, :bootloader_universe_boot_files).returns(false)

    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'keeps legacy downloads when disable_universe is truthy' do
    @host.stubs(:host_param).with('disable_universe').returns('yes')

    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'keeps legacy downloads unless every TFTP proxy supports host boot files' do
    older_proxy = mock('older proxy')
    older_proxy.stubs(:has_feature?).with('TFTP').returns(true)
    older_proxy.stubs(:has_capability?).returns(false)
    older_proxy.stubs(:url).returns('https://older-proxy.example.test')
    subnet6 = mock('IPv6 subnet')
    subnet6.stubs(:tftp).returns(older_proxy)
    @interface.stubs(tftp6?: true, subnet6: subnet6)

    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'keeps legacy downloads for BIOS and other boot loaders' do
    @host.stubs(:pxe_loader_efi?).returns(false)
    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call

    @host.stubs(:pxe_loader_efi?).returns(true)
    @host.stubs(:pxe_loader).returns('PXELinux UEFI')
    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'does not use the universe outside build mode' do
    @host.stubs(:build?).returns(false)

    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'keeps the legacy path when the host medium has no archive URL prefix' do
    @provider.stubs(:boot_file_source_uri).returns('nfs://mirror.example.test/centos/10')

    assert_nil Foreman::BootloaderUniverse::HostBootFiles.new(@host).call
  end

  test 'generic medium providers use their published medium URI' do
    provider_class = Class.new(MediumProviders::Provider) do
      def medium_uri
        URI.parse('https://content.example.test/centos/10')
      end
    end
    @host.stubs(:medium_provider).returns(provider_class.new(nil))

    plan = Foreman::BootloaderUniverse::HostBootFiles.new(@host).call

    assert_equal Digest::SHA256.hexdigest('https://content.example.test/centos/10/images/boot.iso'), plan[:source_digest]
  end

  test 'a managed host uses its medium BootPath for the expected archive source' do
    medium = FactoryBot.build_stubbed(:medium,
      path: 'http://mirror.example.test/centos/$major/$arch',
      boot_path: 'https://boot.example.test/centos/$major/$arch')
    host = FactoryBot.build_stubbed(:host, :managed, :with_tftp_orchestration,
      build: true, pxe_loader: 'Grub2 UEFI', operatingsystem: @os,
      architecture: @architecture, medium: medium)
    host.stubs(:medium_provider).returns(MediumProviders::Default.new(host))
    proxy = host.provision_interface.subnet.tftp
    proxy.stubs(:has_feature?).with('TFTP').returns(true)
    proxy.stubs(:has_capability?).returns(true)

    plan = Foreman::BootloaderUniverse::HostBootFiles.new(host).call

    assert_equal Digest::SHA256.hexdigest('https://boot.example.test/centos/10/x86_64/images/boot.iso'), plan[:source_digest]
  end
end
