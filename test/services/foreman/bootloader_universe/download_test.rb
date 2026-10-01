require 'test_helper'

class Foreman::BootloaderUniverse::DownloadTest < ActiveSupport::TestCase
  setup do
    User.current = users(:admin)
    @architecture = Architecture.new(name: 'x86_64')
    @os = Redhat.new(name: 'Redhat', major: '9', minor: '6')
  end

  test 'redhat extracts bootloader, kernel, and initramdisk from boot ISO into the proxy universe directory' do
    request = @os.bootloader_universe_requests(source_prefix: 'https://mirror.example.test/rhel/9.6/', architecture: @architecture).sole.fetch(:extract)
    directory = 'bootloader-universe/pxegrub2/redhat/9.6/x86_64'

    assert_equal 'https://mirror.example.test/rhel/9.6/images/boot.iso', request[:source]
    assert_equal 'iso', request[:type]
    assert_equal "#{directory}/boot.iso", request[:destination]
    assert_equal 'EFI/BOOT/grubx64.efi', request[:files]["#{directory}/grubx64.efi"]
    assert_equal 'EFI/BOOT/BOOTX64.EFI', request[:files]["#{directory}/shimx64.efi"]
    assert_equal 'images/pxeboot/vmlinuz', request[:files]["#{directory}/vmlinuz"]
    assert_equal 'images/pxeboot/initrd.img', request[:files]["#{directory}/initrd.img"]
    assert_equal 4, request[:files].size
    assert_equal "#{directory}/grubx64.efi", request[:symlinks]["#{directory}/boot.efi"]
  end

  test 'debian uses its release name for the archive and its version for the universe directory' do
    os = Debian.new(name: 'Debian', major: '12', release_name: 'bookworm')
    request = os.bootloader_universe_requests(source_prefix: 'https://deb.example.test/debian', architecture: @architecture).sole.fetch(:extract)

    assert_equal 'https://deb.example.test/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz', request[:source]
    assert_equal 'bootloader-universe/pxegrub2/debian/12/x86_64/netboot.tar.gz', request[:destination]
    assert_equal 'tgz', request[:type]
    assert_equal 'amd64', os.bootloader_source_architecture(@architecture)
    directory = 'bootloader-universe/pxegrub2/debian/12/x86_64'
    assert_equal 'debian-installer/amd64/bootnetx64.efi', request[:files]["#{directory}/shimx64.efi"]
    assert_equal "#{directory}/shimx64.efi", request[:symlinks]["#{directory}/boot-sb.efi"]
  end

  test 'ubuntu uses the separate releases prefix for its archive and ISO' do
    os = Debian.new(name: 'Ubuntu', major: '22.04')
    requests = os.bootloader_universe_requests(source_prefix: 'https://releases.ubuntu.com/', architecture: @architecture)

    assert_equal 'https://releases.ubuntu.com/22.04/ubuntu-22.04-netboot-amd64.tar.gz', requests.first.fetch(:extract).fetch(:source)
    assert_equal 'https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso', requests.second.fetch(:source)
    assert_equal 'bootloader-universe/pxegrub2/ubuntu/22.04/x86_64/boot.iso', requests.second.fetch(:destination)
  end

  test 'unsupported architectures have no universe recipe' do
    assert_empty @os.bootloader_universe_requests(source_prefix: 'https://mirror.example.test', architecture: Architecture.new(name: 'aarch64'))
  end

  test 'medium source uses BootPath and expands source architecture' do
    os = Debian.new(name: 'Debian', major: '12', release_name: 'bookworm')
    os.save!
    architecture = architectures(:x86_64)
    os.architectures << architecture
    medium = FactoryBot.create(:medium, path: 'https://deb.example.test/debian/$arch', boot_path: 'https://boot.example.test/$arch')
    os.media << medium

    source = Foreman::BootloaderUniverse::Download::MediumSource.new(os, id: medium.id)
    assert_equal 'https://boot.example.test/amd64', source.prefix_for(architecture)
  end

  test 'medium source rejects an unassociated medium' do
    medium = FactoryBot.create(:medium)
    assert_raises(Foreman::BootloaderUniverse::Download::InvalidRequest) do
      Foreman::BootloaderUniverse::Download::MediumSource.new(@os, id: medium.id)
    end
  end

  test 'dispatches universe requests only to selected capable proxies' do
    service = service_with_source
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).with do |request|
      request.dig(:extract, :source) == 'https://mirror.example.test/images/boot.iso'
    end.returns(true)

    result = service.call
    assert_equal [{ smart_proxy_id: 42, architecture: 'x86_64', mode: 'universe', accepted: true, request_count: 1 }], result[:results]
  end

  test 'falls back to legacy kernel and initramdisk requests for an older selected proxy' do
    service = service_with_source(prefix: 'http://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 43, url: 'https://old-proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(false)
    @os.stubs(:pxe_files).returns([{ 'boot/kernel' => 'https://mirror.example.test/vmlinuz' }, { 'boot/initrd' => 'https://mirror.example.test/initrd.img' }])
    Net::HTTP.expects(:start).never
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file).twice.returns(true)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).never

    result = service.call
    assert_equal 'legacy', result[:results].sole[:mode]
    assert_equal 2, result[:results].sole[:request_count]
  end

  test 'warns on a missing HTTP boot archive and still sends the proxy request' do
    service = service_with_source(prefix: 'http://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    stub_request(:head, 'http://mirror.example.test/images/boot.iso').to_return(status: 404)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).once.returns(true)

    result = service.call

    assert_equal ['Boot file not available, download will fail: http://mirror.example.test/images/boot.iso'], result[:warnings]
    assert result[:results].sole[:accepted]
    assert_requested(:head, 'http://mirror.example.test/images/boot.iso')
  end

  test 'follows HTTP redirects before deciding whether to warn' do
    service = service_with_source(prefix: 'http://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    stub_request(:head, 'http://mirror.example.test/images/boot.iso').to_return(status: 302, headers: { 'Location' => '/redirected.iso' })
    stub_request(:head, 'http://mirror.example.test/redirected.iso').to_return(status: 200)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).once.returns(true)

    assert_empty service.call[:warnings]
    assert_requested(:head, 'http://mirror.example.test/redirected.iso')
  end

  test 'does not check HTTPS boot archives' do
    service = service_with_source
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    Net::HTTP.expects(:start).never
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).once.returns(true)

    assert_empty service.call[:warnings]
  end

  test 'does not check FTP boot archives' do
    service = service_with_source(prefix: 'ftp://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    Net::HTTP.expects(:start).never
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).once.returns(true)

    assert_empty service.call[:warnings]
  end

  test 'checks the Ubuntu ISO URL as well as its archive URL' do
    @os = Debian.new(name: 'Ubuntu', major: '26.04', release_name: 'resolute')
    service = service_with_source(prefix: 'http://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    archive = 'http://mirror.example.test/26.04/ubuntu-26.04-netboot-amd64.tar.gz'
    iso = 'http://mirror.example.test/26.04/ubuntu-26.04-live-server-amd64.iso'
    stub_request(:head, archive).to_return(status: 200)
    stub_request(:head, iso).to_return(status: 404)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).twice.returns(true)

    result = service.call
    assert_equal ["Boot file not available, download will fail: #{iso}"], result[:warnings]
    assert_equal 2, result[:results].sole[:request_count]
  end

  test 'network errors in the advisory check do not prevent proxy requests' do
    service = service_with_source(prefix: 'http://mirror.example.test')
    proxy = mock('proxy')
    proxy.stubs(id: 42, url: 'https://proxy.example.test')
    service.stubs(:selected_proxies).returns([proxy])
    Foreman::BootloaderUniverse::Download.stubs(:universe_capable?).returns(true)
    stub_request(:head, 'http://mirror.example.test/images/boot.iso').to_raise(SocketError)
    ProxyAPI::TFTP.any_instance.expects(:fetch_boot_file_json).once.returns(true)

    result = service.call
    assert_equal 1, result[:warnings].size
    assert result[:results].sole[:accepted]
  end

  private

  def service_with_source(prefix: 'https://mirror.example.test')
    source = mock('source')
    source.stubs(description: { type: 'medium', id: 7 }, architectures: [@architecture],
      prefix_for: prefix, legacy_provider_for: mock('provider'))
    service = Foreman::BootloaderUniverse::Download.new(operatingsystem: @os, source: { type: 'medium', id: 7 })
    service.stubs(:resolve_source).returns(source)
    service
  end
end
