require 'test_helper'
require 'foreman/util'

class UtilTest < ActiveSupport::TestCase
  include Foreman::Util

  setup do
    ENV.stubs(:[]).with('PRINT_TEST_LOGS_ON_ERROR').returns(false)
    ENV.stubs(:[]).with('PRINT_TEST_LOGS_ON_FAILURE').returns(false)
    ENV.stubs(:[]).with('PRINT_TEST_LOGS_SQL').returns(false)
    ENV.stubs(:[]).with('MINITEST_RETRY_COUNT').returns(1)
  end

  test "should support which" do
    assert :which
  end

  test "should iterate over PATH env and find binary" do
    ENV.stubs(:[]).with('PATH').returns(["/bin", "/usr/bin"])
    FileTest.stubs(:file?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:executable?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:file?).with('/usr/bin/utiltest').returns(true)
    FileTest.stubs(:executable?).with('/usr/bin/utiltest').returns(true)
    assert_equal '/usr/bin/utiltest', which('utiltest')
  end

  test "should prefer binaries in user-supplied user PATH" do
    ENV.stubs(:[]).with('PATH').returns(["/bin", "/usr/bin"])
    FileTest.stubs(:file?).with('/custom/utiltest').returns(true)
    FileTest.stubs(:executable?).with('/custom/utiltest').returns(true)
    FileTest.stubs(:file?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:executable?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:file?).with('/usr/bin/utiltest').returns(true)
    FileTest.stubs(:executable?).with('/usr/bin/utiltest').returns(true)
    assert_equal '/custom/utiltest', which('utiltest', ['/custom'])
  end

  test "should return false when binary not found in PATH" do
    ENV.stubs(:[]).with('PATH').returns(["/bin", "/usr/bin"])
    FileTest.stubs(:file?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:executable?).with('/bin/utiltest').returns(false)
    FileTest.stubs(:file?).with('/usr/bin/utiltest').returns(false)
    FileTest.stubs(:executable?).with('/usr/bin/utiltest').returns(false)
    assert_equal false, which('utiltest')
  end

  test 'secure_encryption_key should match AS default key length' do
    assert_equal ActiveSupport::MessageEncryptor.key_len, secure_encryption_key.length
  end
end
