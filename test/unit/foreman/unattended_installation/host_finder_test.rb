require 'test_helper'

class Foreman::UnattendedInstallation::HostFinderTest < ActiveSupport::TestCase
  subject { Foreman::UnattendedInstallation::HostFinder }
  let(:host) { FactoryBot.create(:host, :managed, build: true) }

  context 'search' do
    it 'finds a host by spoof' do
      finder = subject.new(query_params: { spoof: host.ip })

      assert_equal host, finder.search
      assert_equal(["spoof: #{host.ip}"], finder.search_paths)
    end

    it 'finds a host by hostname' do
      finder = subject.new(query_params: { hostname: host.name })

      assert_equal host, finder.search
      assert_equal(["hostname: #{host.name}"], finder.search_paths)
    end

    it 'finds a host by token' do
      finder = subject.new(query_params: { token: host.token.value })

      assert_equal host, finder.search
      assert_equal(["token: [redacted]"], finder.search_paths)
    end

    it 'finds a host by mac address' do
      mac_list = [host.mac, '00:53:66:ab:66:67']
      finder = subject.new(query_params: { mac_list: mac_list, ip: host.ip })

      assert_equal host, finder.search
      assert_equal(["mac: #{mac_list.join(', ')}"], finder.search_paths)
    end

    it 'finds a host by ip address' do
      finder = subject.new(query_params: { ip: host.ip })

      assert_equal host, finder.search
      assert_equal(["ip: #{host.ip}"], finder.search_paths)
    end

    it 'searchs by spoof, hostname and mac address' do
      mac_list = [host.mac, '00:53:66:ab:66:67']
      params = { spoof: '127.0.66.66', hostname: 'invalid-hostname', mac_list: mac_list, ip: host.ip }
      finder = subject.new(query_params: params)

      assert_equal host, finder.search
      assert_equal(["spoof: 127.0.66.66", "hostname: invalid-hostname", "mac: #{mac_list.join(', ')}"], finder.search_paths)
    end

    it 'searchs by spoof, hostname and ip address' do
      params = { spoof: '127.0.66.66', hostname: 'invalid-hostname', ip: host.ip }
      finder = subject.new(query_params: params)

      assert_equal host, finder.search
      assert_equal(["spoof: 127.0.66.66", "hostname: invalid-hostname", "ip: #{host.ip}"], finder.search_paths)
    end

    it 'skips search by ip & mac when token is present' do
      params = { token: host.token.value, ip: host.ip, mac_list: [host.mac] }
      finder = subject.new(query_params: params)

      assert_equal host, finder.search
      assert_equal(["token: [redacted]"], finder.search_paths)
    end
  end
end
