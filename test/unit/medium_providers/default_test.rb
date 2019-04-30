require 'test_helper'

class DefaultMediumProviderTest < ActiveSupport::TestCase
  test 'returns default provider for managed host' do
    host = FactoryBot.create(:host, :managed)
    medium_provider = Foreman::Plugin.medium_providers.find_provider(host)
    assert_instance_of MediumProviders::Default, medium_provider
  end

  test 'interpolated $version does not include dots if only major is specified' do
    operatingsystem = FactoryBot.build_stubbed(:operatingsystem, :name => 'foo', :major => '4')
    architecture = FactoryBot.build_stubbed(:architecture, :name => 'x64')
    mock_entity = OpenStruct.new(operatingsystem: operatingsystem, architecture: architecture)

    provider = MediumProviders::Default.new(mock_entity)

    result_path = provider.interpolate_vars('http://foo.org/$version')
    assert result_path, 'http://foo.org/4'
  end

  [["Redhat", "http://mirror.centos.org/centos/6.0/os/x86_64", ["images/pxeboot/vmlinuz", "images/pxeboot/initrd.img"]],
   ["Ubuntu", "http://archive.ubuntu.com/", ["dists/rn10/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux", "dists/rn10/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz"]],
   ["OpenSuse", "http://download.opensuse.org/distribution/12.3/repo/oss", ["boot/x86_64/loader/linux", "boot/x86_64/loader/initrd"]],
   ["Solaris", "http://www.example.com/vol/solgi_5.10/sol10_hw0910_sparc", ["Solaris_10/Tools/Boot/x86.miniroot", "Solaris_10/Tools/Boot/multiboot"]]].each do |osname, expected_uri, pxe_files|
    test "generates URI for #{osname}" do
      pxe_files.each do |file|
        stub_request(:head, "#{expected_uri}/#{file}").to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
      end
      host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name(osname))
      assert_equal expected_uri, MediumProviders::Default.new(host).medium_uri.to_s
    end
  end

  test "handles HTTP HEAD redirect with last modified" do
    redirection = "http://example.com/redirect"
    stub_request(:head, %r'http://mirror.centos.org/centos/6.0/os/x86_64/images/pxeboot/(vmlinuz|initrd.img)').to_return(status: 301, headers: { 'Location' => redirection })
    stub_request(:head, %r'http://example.com/redirect').to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
    host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    assert_equal "centos-5-4-tg0SG0OK", MediumProviders::Default.new(host).unique_id.to_s
  end

  test "handles HTTP HEAD redirect with etag" do
    redirection = "http://example.com/redirect"
    stub_request(:head, %r'http://mirror.centos.org/centos/6.0/os/x86_64/images/pxeboot/(vmlinuz|initrd.img)').to_return(status: 301, headers: { 'Location' => redirection })
    stub_request(:head, %r'http://example.com/redirect').to_return(status: 200, body: "", headers: {'ETag': "zzz"})
    host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    assert_equal "centos-5-4-QPo37ADH", MediumProviders::Default.new(host).unique_id.to_s
  end

  test "handles HTTP HEAD redirect without any headers" do
    redirection = "http://example.com/redirect"
    stub_request(:head, %r'http://mirror.centos.org/centos/6.0/os/x86_64/images/pxeboot/(vmlinuz|initrd.img)').to_return(status: 301, headers: { 'Location' => redirection })
    stub_request(:head, %r'http://example.com/redirect').to_return(status: 200, body: "")
    host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    assert_equal "centos-5-4-B0hJnFEY", MediumProviders::Default.new(host).unique_id.to_s
  end

  [["centos-5-4-tg0SG0OK", "Redhat", "http://mirror.centos.org/centos/6.0/os/x86_64/images/pxeboot", ["vmlinuz", "initrd.img"]],
   ["ubuntu-mirror-tg0SG0OK", "Ubuntu", "http://archive.ubuntu.com/dists/rn10/main/installer-x86_64/current/images/netboot/ubuntu-installer/x86_64", ["linux", "initrd.gz"]],
   ["opensuse-tg0SG0OK", "OpenSuse", "http://download.opensuse.org/distribution/12.3/repo/oss/boot/x86_64/loader", ["linux", "initrd"]],
   ["solaris-10-tg0SG0OK", "Solaris", "http://www.example.com/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot", ["x86.miniroot", "multiboot"]]].each do |expected_id, osname, expected_uri, pxe_files|
    test "generates unique ID based on base and pxedir for #{osname}" do
      pxe_files.each do |file|
        url = "#{expected_uri}/#{file}"
        url.gsub!('x86_64', 'amd64') if osname == "Ubuntu"
        stub_request(:head, url).to_return(status: 200, body: "", headers: {'Last-Modified': 'xxx', 'ETag': "zzz"})
      end
      host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name(osname))
      medium_uri_with_path = MediumProviders::Default.new(host).medium_uri(host.operatingsystem.pxedir).to_s
      assert_equal expected_uri, medium_uri_with_path
      assert_equal expected_id, MediumProviders::Default.new(host).unique_id.to_s
    end
  end

  test 'returns additional_media from host params' do
    additional_media = [{'name' => 'EPEL', 'url' => 'http://yum.example.com/epel'}]
    host = FactoryBot.build_stubbed(:host, :managed, :redhat)
    FactoryBot.create(:host_parameter,
                      host: host,
                      name: 'additional_media',
                      value: additional_media.to_json)

    assert_equal MediumProviders::Default.new(host).additional_media, additional_media
  end
end
