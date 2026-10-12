require 'test_helper'

class Foreman::BruteforceProtectionTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  teardown do
    Rails.cache.clear
  end

  let(:subject) do
    ::Foreman::BruteforceProtection.new(
      request_ip: '127.0.0.1'
    )
  end

  it 'reads and updates login failure counts' do
    assert_equal 0, subject.get_login_failures
    refute Rails.cache.exist?('failed_login_v2_127.0.0.1')

    10.times.each do
      subject.count_login_failure
    end

    assert_equal 10, subject.get_login_failures
  end

  it 'detects brute force attemps' do
    assert_equal false, subject.bruteforce_attempt?

    31.times.each do
      subject.count_login_failure
    end

    assert_equal true, subject.bruteforce_attempt?
  end

  it 'does not write a cache entry without an IP address' do
    protection = ::Foreman::BruteforceProtection.new(request_ip: nil)
    Setting.stubs(:[]).with(:failed_login_attempts_limit).returns(1)

    assert_nil protection.count_login_failure
    assert_equal 0, protection.get_login_failures
    assert_equal false, protection.bruteforce_attempt?
  end
end
