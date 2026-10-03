require 'test_helper'
require Rails.root.join('lib/foreman/active_storage_config')

class ActiveStorageConfigTest < ActiveSupport::TestCase
  test 'uses local storage by default' do
    assert_equal :local, Foreman::ActiveStorageConfig.new({}).service
  end

  test 'accepts S3 with workload identity credentials' do
    settings = {active_storage: {service: 's3', s3: {bucket: 'foreman', region: 'us-east-1'}}}

    assert_equal :s3, Foreman::ActiveStorageConfig.new(settings).service
  end

  test 'accepts S3 with explicit credentials' do
    settings = {
      active_storage: {
        service: 's3',
        s3: {
          bucket: 'foreman',
          region: 'us-east-1',
          access_key_id: 'access-key',
          secret_access_key: 'secret-key',
        },
      },
    }

    assert_equal :s3, Foreman::ActiveStorageConfig.new(settings).service
  end

  test 'rejects an unsupported service' do
    error = assert_raises(ArgumentError) do
      Foreman::ActiveStorageConfig.new(active_storage: {service: 'unknown'}).service
    end

    assert_match(/Unsupported Active Storage service/, error.message)
  end

  test 'requires S3 bucket and region' do
    error = assert_raises(ArgumentError) do
      Foreman::ActiveStorageConfig.new(active_storage: {service: 's3', s3: {}}).service
    end

    assert_equal 'Missing Active Storage S3 settings: bucket, region', error.message
  end

  test 'requires explicit S3 credentials as a pair' do
    settings = {
      active_storage: {
        service: 's3',
        s3: {bucket: 'foreman', region: 'us-east-1', access_key_id: 'access-key'},
      },
    }

    error = assert_raises(ArgumentError) { Foreman::ActiveStorageConfig.new(settings).service }

    assert_equal 'Active Storage S3 access key and secret key must be configured together', error.message
  end
end
