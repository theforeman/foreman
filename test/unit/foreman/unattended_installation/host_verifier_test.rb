require 'test_helper'

class Foreman::UnattendedInstallation::HostVerifierTest < ActiveSupport::TestCase
  subject { Foreman::UnattendedInstallation::HostVerifier }

  context 'host_found?' do
    it 'error message includes search method when host is not found' do
      search_paths = ["spoof: 127.0.0.1", "hostname: test-hostname", "token: [redacted]", "ip: 127.0.0.1", "mac: 00:00:00:00:00:00, 00:00:00:00:00:01"]

      search_paths.each do |search_path|
        verifier = subject.new(nil, search_paths: [search_path], request_ip: '127.0.0.1', for_host_template: false)
        refute verifier.valid?
        error = verifier.errors.first

        refute_nil error
        assert_equal :not_found, error[:type]
        assert_includes error[:message], "search_paths"
        assert_equal search_path, error.dig(:params, :search_paths)
      end
    end
  end

  context 'valid_host_token? with per-OS token enforcement' do
    def verifier_for(host, token: nil)
      subject.new(host, request_ip: '127.0.0.1', for_host_template: true, search_paths: [], token: token)
    end

    def stub_host(token_enforced:, token_value: nil, token_expired: false, build: true)
      os = mock('operatingsystem')
      os.stubs(:token_enforced?).returns(token_enforced)
      stored_token = token_value && stub(value: token_value)
      host = mock('host')
      host.stubs(:operatingsystem).returns(os)
      host.stubs(:name).returns('host.example.com')
      host.stubs(:token).returns(stored_token)
      host.stubs(:token_expired?).returns(token_expired)
      host.stubs(:build?).returns(build)
      host
    end

    setup do
      Setting[:token_duration] = 360
    end

    it 'allows an IP/MAC matched host when its OS does not enforce a token' do
      host = stub_host(token_enforced: false)
      assert verifier_for(host).send(:valid_host_token?)
    end

    it 'refuses when the OS enforces a token but none is provided' do
      host = stub_host(token_enforced: true, token_value: 'the-token')
      verifier = verifier_for(host, token: nil)
      refute verifier.send(:valid_host_token?)
      assert_equal :unauthorized, verifier.errors.first[:type]
    end

    it 'refuses when the OS enforces a token and a wrong token is provided' do
      host = stub_host(token_enforced: true, token_value: 'the-token')
      refute verifier_for(host, token: 'wrong-token').send(:valid_host_token?)
    end

    it 'allows when the OS enforces a token and the matching token is provided' do
      host = stub_host(token_enforced: true, token_value: 'the-token')
      assert verifier_for(host, token: 'the-token').send(:valid_host_token?)
    end

    it 'refuses when the OS enforces a token and the matching token has expired' do
      host = stub_host(token_enforced: true, token_value: 'the-token', token_expired: true)
      refute verifier_for(host, token: 'the-token').send(:valid_host_token?)
    end

    it 'is inert when installation tokens are disabled globally' do
      Setting[:token_duration] = 0
      host = stub_host(token_enforced: true, token_value: nil)
      assert verifier_for(host, token: nil).send(:valid_host_token?)
    end

    it 'does not require a token for a host that is not in build mode' do
      host = stub_host(token_enforced: true, token_value: 'the-token', build: false)
      assert verifier_for(host, token: nil).send(:valid_host_token?)
    end
  end
end
