require 'test_helper'
require 'tmpdir'

class ActiveStorageMigratorTest < ActiveSupport::TestCase
  setup do
    @root = Dir.mktmpdir
    @source = ActiveStorage::Service::DiskService.new(:root => File.join(@root, 'source'))
    @destination = ActiveStorage::Service::DiskService.new(:root => File.join(@root, 'destination'))
    @source.name = 'migration_source'
    @destination.name = 'migration_destination'
    @services = { 'migration_source' => @source, 'migration_destination' => @destination }
    ActiveStorage::Blob.stubs(:services).returns(@services)
    @content = 'a stored attachment'
    @blob = ActiveStorage::Blob.create_and_upload!(
      :io => StringIO.new(@content), :filename => 'report.txt',
      :content_type => 'text/plain', :service_name => 'migration_source'
    )
    @output = StringIO.new
  end

  teardown do
    @blob.purge if @blob.persisted?
    FileUtils.remove_entry(@root)
  end

  test 'previews without copying or changing the service' do
    result = migrate(:apply => false)

    assert_equal 1, result[:planned]
    assert_equal 'migration_source', @blob.reload.service_name
    refute @destination.exist?(@blob.key)
  end

  test 'copies verified bytes while preserving metadata and source objects' do
    key = @blob.key
    attachment = ActiveStorage::Attachment.create!(
      :name => 'migration_test', :record => users(:one), :blob => @blob
    )

    assert_equal 1, migrate[:copied]
    assert_equal 'migration_destination', @blob.reload.service_name
    assert_equal @content, @blob.download
    assert_equal @content, @source.download(key)
    assert_equal key, @blob.key
    assert_equal 'report.txt', @blob.filename.to_s
    assert_equal @blob.id, attachment.reload.blob_id
  end

  test 'reruns do not create extra blobs or repeat completed copies' do
    migrate

    assert_no_difference('ActiveStorage::Blob.count') do
      assert_equal 0, migrate[:copied]
    end
  end

  test 'reuses a verified destination left by an interrupted copy' do
    @destination.upload(@blob.key, StringIO.new(@content), :checksum => @blob.checksum)
    @destination.expects(:upload).never

    assert_equal 1, migrate[:copied]
    assert_equal 'migration_destination', @blob.reload.service_name
  end

  test 'does not overwrite a mismatched destination' do
    @destination.upload(@blob.key, StringIO.new('wrong data'))

    assert_equal 1, migrate[:failed]
    assert_equal 'migration_source', @blob.reload.service_name
    assert_equal 'wrong data', @destination.download(@blob.key)
    assert_equal @content, @source.download(@blob.key)
  end

  test 'a failed upload does not switch the blob service' do
    @destination.expects(:upload).raises(IOError, 'storage unavailable')

    assert_equal 1, migrate[:failed]
    assert_equal 'migration_source', @blob.reload.service_name
    assert_equal @content, @blob.download
  end

  test 'a corrupted destination readback is detected before switching the service' do
    @destination.stubs(:download).yields('wrong upload')

    assert_equal 1, migrate[:failed]
    assert_equal 'migration_source', @blob.reload.service_name
    assert_equal @content, @source.download(@blob.key)
  end

  test 'a missing source fails without changing the database' do
    @source.delete(@blob.key)

    assert_equal 1, migrate[:failed]
    assert_equal 'migration_source', @blob.reload.service_name
  end

  test 'a corrupted source is not copied' do
    @source.upload(@blob.key, StringIO.new('corrupt'))

    assert_equal 1, migrate[:failed]
    assert_equal 'migration_source', @blob.reload.service_name
    refute @destination.exist?(@blob.key)
  end

  test 'can roll back to the retained source service' do
    migrate

    result = Foreman::ActiveStorageMigrator.new(
      :source => 'migration_destination', :destination => 'migration_source',
      :apply => true, :output => @output
    ).run

    assert_equal 1, result[:copied]
    assert_equal 'migration_source', @blob.reload.service_name
    assert_equal @content, @blob.download
  end

  test 'rejects unknown services and identical source and destination' do
    assert_raises(KeyError) do
      Foreman::ActiveStorageMigrator.new(:source => 'migration_source', :destination => 'unknown')
    end
    assert_raises(ArgumentError) do
      Foreman::ActiveStorageMigrator.new(:source => 'migration_source', :destination => 'migration_source')
    end
  end

  private

  def migrate(apply: true)
    Foreman::ActiveStorageMigrator.new(
      :source => 'migration_source', :destination => 'migration_destination',
      :apply => apply, :output => @output
    ).run
  end
end
