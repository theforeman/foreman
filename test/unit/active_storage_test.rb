require 'test_helper'

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
end
