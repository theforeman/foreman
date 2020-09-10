require 'test_helper'

class NicIpResolverTest < ActiveSupport::TestCase
  describe '#to_ip_address' do
    let(:host) { FactoryBot.build_stubbed(:host) }
    let(:nic) { host.provision_interface }
    let(:resolver) { NicIpResolver.new(:nic => nic) }

    test 'uses host PTR4 record to lookup the IP when present' do
      stub_dns_record = stub()
      nic.expects(:dns_record).with(:ptr4).returns(stub_dns_record).twice
      stub_dns_record.expects(:dns_lookup).with('foo').
        returns(OpenStruct.new(:ip => '127.0.0.1'))
      assert '127.0.0.1', resolver.to_ip_address('foo')
    end

    test 'when IP is passed as argument, return it' do
      assert '127.0.0.1', resolver.to_ip_address('127.0.0.1')
    end

    test 'call host domain resolver if there is no PTR4 record' do
      host.domain = FactoryBot.build_stubbed(:domain)
      host.domain.expects(:nameservers).returns('8.8.8.8')
      Resolv::DNS.any_instance.expects(:getaddress).with('foo')
        .returns('127.0.0.1')
      assert '127.0.0.1', resolver.to_ip_address('foo')
    end

    test 'raises exception when any error happens (no domain)' do
      assert_raises(::Foreman::WrappedException) do
        resolver.to_ip_address('foo')
      end
    end
  end
end
