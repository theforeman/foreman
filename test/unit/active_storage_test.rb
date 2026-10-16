require 'test_helper'
require Rails.root.join('lib/foreman/active_storage_config')

class ActiveStorageTest < ActiveSupport::TestCase
  test 'uses isolated disk storage in the test environment' do
    assert_equal :test, Rails.application.config.active_storage.service
    assert_kind_of ActiveStorage::Service::DiskService, ActiveStorage::Blob.service
    assert_equal Rails.root.join('tmp/storage-test').to_s, ActiveStorage::Blob.service.root
  end

  test 'stores and retrieves a blob' do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('active storage test'),
      filename: 'test.txt',
      content_type: 'text/plain'
    )

    assert_equal 'active storage test', blob.download
  ensure
    blob&.purge
  end

  test 'does not expose generic attachment routes' do
    refute Rails.application.config.active_storage.draw_routes
    refute_includes Rails.application.routes.named_routes.names, :rails_service_blob
  end

  test 'quotes S3-compatible settings safely' do
    original_settings = SETTINGS[:active_storage]
    SETTINGS[:active_storage] = {
      service: 's3',
      s3: {
        access_key_id: 'access:key',
        secret_access_key: 'secret#key',
        region: 'us-east-1',
        bucket: 'foreman',
        endpoint: 'https://minio.example.com',
        force_path_style: true,
      },
    }

    rendered = ERB.new(Rails.root.join('config/storage.yml').read).result
    services = YAML.safe_load(rendered)

    assert_equal 'S3', services.dig('s3', 'service')
    assert_equal 'access:key', services.dig('s3', 'access_key_id')
    assert_equal 'secret#key', services.dig('s3', 'secret_access_key')
    assert_equal 'https://minio.example.com', services.dig('s3', 'endpoint')
    assert services.dig('s3', 'force_path_style')
  ensure
    SETTINGS[:active_storage] = original_settings
  end
end
