require 'test_helper'

class NormalizeCacertTest < ActiveSupport::TestCase
  test 'normalizes cacert CRLF line endings to LF on save' do
    cacert = File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt')).chomp
    proxy = FactoryBot.build(:http_proxy, :cacert => cacert.gsub("\n", "\r\n"))

    assert proxy.save
    assert_equal cacert, proxy.cacert
    refute_includes proxy.cacert, "\r"
  end
end
