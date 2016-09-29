require 'test_helper'
require 'net'
require 'net/dns'

class DnsTest < ActiveSupport::TestCase
  setup do
    @proxy = smart_proxies(:one)
  end

  context "#lookup" do
    test "should return nil for empty query" do
      result = Net::DNS.lookup('', :proxy => @proxy)
      assert_nil result
    end

    test "should do a forward ipv4 lookup" do
      resource = mock()
      resource.stubs(:address).returns('1.1.1.1')
      Resolv::DNS.any_instance.expects(:getresource).with('www.example.com', Resolv::DNS::Resource::IN::A).returns(resource)
      result = Net::DNS.lookup('www.example.com', :proxy => @proxy)
      assert_kind_of Net::DNS::ARecord, result
      assert_equal 'www.example.com', result.hostname
    end

    test "should do a forward ipv6 lookup" do
      resource = mock()
      resource.stubs(:address).returns('2001:db8::1')
      Resolv::DNS.any_instance.expects(:getresource).with('www.example.com', Resolv::DNS::Resource::IN::AAAA).returns(resource)
      result = Net::DNS.lookup('www.example.com', :proxy => @proxy, :ipfamily => Socket::AF_INET6)
      assert_kind_of Net::DNS::AAAARecord, result
      assert_equal 'www.example.com', result.hostname
    end

    test "should do a reverse ipv4 lookup" do
      Resolv::DNS.any_instance.expects(:getname).returns('www.example.com')
      result = Net::DNS.lookup('1.1.1.1', :proxy => @proxy)
      assert_kind_of Net::DNS::PTR4Record, result
      assert_equal '1.1.1.1', result.ip
    end

    test "should do a reverse ipv6 lookup" do
      Resolv::DNS.any_instance.expects(:getname).returns('www.example.com')
      result = Net::DNS.lookup('2001:db8::1', :proxy => @proxy)
      assert_kind_of Net::DNS::PTR6Record, result
      assert_equal '2001:db8::1', result.ip
    end
  end

  context "records" do
    setup do
      Resolv::DNS.any_instance.stubs(:getname).returns('www.example.com')
      resource_v4 = mock()
      resource_v4.stubs(:address).returns('1.2.3.4')
      Resolv::DNS.any_instance.stubs(:getresource).with('www.example.com', Resolv::DNS::Resource::IN::A).returns(resource_v4)
      resource_v6 = mock()
      resource_v6.stubs(:address).returns('2001:db8::1')
      Resolv::DNS.any_instance.stubs(:getresource).with('www.example.com', Resolv::DNS::Resource::IN::AAAA).returns(resource_v6)
    end

    context "a IPv4 forward record" do
      setup do
        @record = Net::DNS::ARecord.new(:hostname => 'www.example.com', :ip => '1.2.3.4', :proxy => @proxy)
      end

      test 'should have a IPv4 reverse record' do
        reverse_record = @record.ptr
        assert_kind_of Net::DNS::PTR4Record, reverse_record
        assert_equal reverse_record.ip, '1.2.3.4'
      end
    end

    context "a IPv4 reverse record" do
      setup do
        @record = Net::DNS::PTR4Record.new(:hostname => 'www.example.com', :ip => '1.2.3.4', :proxy => @proxy)
      end

      test 'should have a IPv4 forward record' do
        forward_record = @record.a
        assert_kind_of Net::DNS::ARecord, forward_record
        assert_equal forward_record.hostname, 'www.example.com'
      end

      test 'should have a IPv6 forward record' do
        forward_record = @record.aaaa
        assert_kind_of Net::DNS::AAAARecord, forward_record
        assert_equal forward_record.hostname, 'www.example.com'
      end
    end

    context "a IPv6 forward record" do
      setup do
        @record = Net::DNS::AAAARecord.new(:hostname => 'www.example.com', :ip => '2001:db8::1', :proxy => @proxy)
      end

      test 'should have a IPv6 reverse record' do
        reverse_record = @record.ptr
        assert_kind_of Net::DNS::PTR6Record, reverse_record
        assert_equal reverse_record.ip, '2001:db8::1'
      end
    end

    context "a IPv6 reverse record" do
      setup do
        @record = Net::DNS::PTR6Record.new(:hostname => 'www.example.com', :ip => '2001:db8::1', :proxy => @proxy)
      end

      test 'should have a IPv4 forward record' do
        forward_record = @record.a
        assert_kind_of Net::DNS::ARecord, forward_record
        assert_equal forward_record.hostname, 'www.example.com'
      end

      test 'should have a IPv6 forward record' do
        forward_record = @record.aaaa
        assert_kind_of Net::DNS::AAAARecord, forward_record
        assert_equal forward_record.hostname, 'www.example.com'
      end
    end
  end
end
