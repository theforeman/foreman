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
end
