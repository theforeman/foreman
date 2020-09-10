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

  [["Redhat", "http://mirror.centos.org/centos/6.0/os/x86_64"],
   ["Ubuntu", "http://sg.archive.ubuntu.com/"],
   ["OpenSuse", "http://download.opensuse.org/distribution/12.3/repo/oss"],
   ["Solaris", "http://brsla01/vol/solgi_5.10/sol10_hw0910_sparc"]].each do |osname, expected_uri|
    test "generates URI for #{osname}" do
      host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name(osname))
      assert_equal expected_uri, MediumProviders::Default.new(host).medium_uri.to_s
    end
  end

  [["Redhat", "http://mirror.centos.org/centos/6.0/os/x86_64/images/pxeboot"],
   ["Ubuntu", "http://sg.archive.ubuntu.com/dists/rn10/main/installer-x86_64/current/images/netboot/ubuntu-installer/x86_64"],
   ["OpenSuse", "http://download.opensuse.org/distribution/12.3/repo/oss/boot/x86_64/loader"],
   ["Solaris", "http://brsla01/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot"]].each do |osname, expected_uri|
    test "generates unique ID based on base and pxedir for #{osname}" do
      host = FactoryBot.build_stubbed(:host, :managed, :operatingsystem => Operatingsystem.find_by_name(osname))
      medium_uri_with_path = MediumProviders::Default.new(host).medium_uri(host.operatingsystem.pxedir).to_s
      assert_equal expected_uri, medium_uri_with_path
      digest = Base64.urlsafe_encode64(Digest::SHA1.digest(medium_uri_with_path + host.operatingsystem.major + host.operatingsystem.minor), padding: false)
      expected_id = "#{host.medium.name.parameterize}-#{digest.gsub(/[-_]/, '')[1..12]}"
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
