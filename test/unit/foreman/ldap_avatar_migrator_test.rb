require 'test_helper'
require 'tmpdir'
require 'base64'

class LdapAvatarMigratorTest < ActiveSupport::TestCase
  setup do
    @root = Pathname.new(Dir.mktmpdir)
    Rails.stubs(:public_path).returns(@root)
    @content = Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVQYV2P4DwABAQEAWk1v8QAAAABJRU5ErkJggg==')
    @user = FactoryBot.create(:user, :avatar_hash => Digest::SHA1.hexdigest(@content))
    @path = @root.join('images', 'avatars', "#{@user.avatar_hash}.jpg")
    FileUtils.mkdir_p(@path.dirname)
    @path.binwrite(@content)
    @output = StringIO.new
  end

  teardown do
    @user.avatar.purge if @user.avatar.attached?
    FileUtils.remove_entry(@root)
  end

  test 'previews without attaching or deleting files' do
    result = Foreman::LdapAvatarMigrator.new(:output => @output).run

    assert_equal 1, result[:planned]
    refute @user.reload.avatar.attached?
    assert_equal @content, @path.binread
  end

  test 'copies and verifies a legacy image without deleting the source' do
    result = migrate

    assert_equal 1, result[:copied]
    assert_equal @content, @user.reload.avatar.download
    assert_equal 'image/png', @user.avatar.content_type
    assert_equal @content, @path.binread
  end

  test 'rerunning a migration does not create another blob' do
    migrate

    assert_no_difference('ActiveStorage::Blob.count') do
      assert_equal 1, migrate[:skipped]
    end
  end

  test 'does not overwrite an existing attachment' do
    @user.avatar.attach(:io => StringIO.new('newer avatar'), :filename => 'new.png')

    assert_equal 1, migrate[:skipped]
    assert_equal 'newer avatar', @user.reload.avatar.download
  end

  test 'reports missing files' do
    @path.delete

    assert_equal 1, migrate[:missing]
    refute @user.reload.avatar.attached?
  end

  test 'refuses corrupt image content' do
    @path.binwrite('corrupt image')

    assert_equal 1, migrate[:failed]
    refute @user.reload.avatar.attached?
    assert_equal 'corrupt image', @path.binread
  end

  test 'accepts legacy filenames hashed before Base64 decoding' do
    hash = Digest::SHA1.hexdigest(Base64.encode64(@content))
    @user.update_column(:avatar_hash, hash)
    @path.rename(@path.dirname.join("#{hash}.jpg"))

    assert_equal 1, migrate[:copied]
    assert_equal @content, @user.reload.avatar.download
  end

  test 'does not read a path outside the avatar directory' do
    @user.update_column(:avatar_hash, '../outside')

    assert_nil @user.legacy_avatar_path
    assert_equal 1, migrate[:missing]
  end

  test 'does not follow symbolic links' do
    @path.delete
    @path.make_symlink(@root.join('outside'))

    assert_nil @user.legacy_avatar_path
    assert_equal 1, migrate[:missing]
  end

  test 'reports upload failures and retains the old file' do
    ActiveStorage::Blob.any_instance.expects(:upload).raises(IOError, 'storage unavailable')

    assert_no_difference('ActiveStorage::Blob.count') do
      assert_equal 1, migrate[:failed]
    end
    refute @user.reload.avatar.attached?
    assert_equal @content, @path.binread
  end

  test 'does not attach a failed readback and removes its unused blob' do
    ActiveStorage::Blob.any_instance.stubs(:download).returns('different bytes')

    assert_no_difference('ActiveStorage::Blob.count') do
      assert_equal 1, migrate[:failed]
    end
    refute @user.reload.avatar.attached?
    assert_equal @content, @path.binread
  end

  private

  def migrate
    Foreman::LdapAvatarMigrator.new(:apply => true, :output => @output).run
  end
end
