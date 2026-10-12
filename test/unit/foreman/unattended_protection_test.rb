require 'test_helper'

class Foreman::UnattendedProtectionTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    Setting[:unattended_attempts_limit] = 3
  end

  teardown do
    Rails.cache.clear
  end

  let(:subject) do
    ::Foreman::UnattendedProtection.new(
      request_ip: '127.0.0.1'
    )
  end

  it 'allows requests up to the configured limit and blocks the next one' do
    assert_equal 0, subject.get_unattended_attempts
    refute Rails.cache.exist?('unattended_attempts_v1_127.0.0.1')

    3.times { assert_equal false, subject.rate_limited? }

    assert_equal 3, subject.get_unattended_attempts
    assert_equal true, subject.rate_limited?
  end

  it 'does not limit requests when protection is disabled' do
    Setting[:unattended_attempts_limit] = 0

    10.times { assert_equal false, subject.rate_limited? }
  end

  it 'does not write a cache entry without an IP address' do
    protection = ::Foreman::UnattendedProtection.new(request_ip: nil)

    assert_equal 0, protection.get_unattended_attempts
    assert_equal false, protection.rate_limited?
  end

  it 'allows requests when the cache cannot count them' do
    Rails.cache.stubs(:increment).returns(nil)

    assert_equal false, subject.rate_limited?
  end
end
