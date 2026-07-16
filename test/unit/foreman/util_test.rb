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

  test 'ssl_cert_store returns nil when cacert is blank' do
    Foreman::Util.expects(:add_ca_bundle_to_store).never
    assert_nil Foreman::Util.ssl_cert_store
    assert_nil Foreman::Util.ssl_cert_store('')
  end

  test 'ssl_cert_store pins to cacert without system defaults when present' do
    cacert = File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt'))
    OpenSSL::X509::Store.any_instance.expects(:set_default_paths).never
    Foreman::Util.expects(:add_ca_bundle_to_store).with(cacert, instance_of(OpenSSL::X509::Store))
    Foreman::Util.ssl_cert_store(cacert)
  end

  test 'normalize_line_endings converts CRLF and CR line endings to LF' do
    assert_equal "a\nb\nc\n", Foreman::Util.normalize_line_endings("a\r\nb\rc\r\n")
    assert_nil Foreman::Util.normalize_line_endings(nil)
    assert_equal '', Foreman::Util.normalize_line_endings('')
  end

  test 'ssl_cert_store accepts cacert with CRLF line endings' do
    cacert = File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt')).gsub("\n", "\r\n")
    assert_instance_of OpenSSL::X509::Store, Foreman::Util.ssl_cert_store(cacert)
  end
end
