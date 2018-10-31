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
