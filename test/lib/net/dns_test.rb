require 'test_helper'
require 'net'
require 'net/dns'

class DnsTest < ActiveSupport::TestCase
  context "#lookup" do
    setup do
      @proxy = smart_proxies(:one)
    end

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
    end

    test "should do a forward ipv6 lookup" do
      resource = mock()
      resource.stubs(:address).returns('2001:db8::1')
      Resolv::DNS.any_instance.expects(:getresource).with('www.example.com', Resolv::DNS::Resource::IN::AAAA).returns(resource)
      result = Net::DNS.lookup('www.example.com', :proxy => @proxy, :ipversion => 6)
      assert_kind_of Net::DNS::AAAARecord, result
    end

    test "should do a reverse ipv4 lookup" do
      Resolv::DNS.any_instance.expects(:getname).returns('www.example.com')
      result = Net::DNS.lookup('1.1.1.1', :proxy => @proxy)
      assert_kind_of Net::DNS::PTR4Record, result
    end

    test "should do a reverse ipv6 lookup" do
      Resolv::DNS.any_instance.expects(:getname).returns('www.example.com')
      result = Net::DNS.lookup('2001:db8::1', :proxy => @proxy)
      assert_kind_of Net::DNS::PTR6Record, result
    end
  end
end
