require 'test_helper'
require 'net'

class DhcpTest < ActiveSupport::TestCase

  test "dhcp record should not be created without a mac" do
    assert_raise Net::Validations::Error do
      Net::DhcpRecord.new :name => "test", "proxy" => smart_proxies(:one)
    end
  end

  test "dhcp record should not be created without a network" do
    assert_raise Net::Validations::Error do
      Net::DhcpRecord.new :name => "test", :mac => "aa:bb:cc:dd:ee:ff", "proxy" => smart_proxies(:one)
    end
  end

  test "dhcp record should not be created without an ip" do
    assert_raise Net::Validations::Error do
      Net::DhcpRecord.new :name => "test", :mac => "aa:bb:cc:dd:ee:ff", :network => "127.0.0.0", "proxy" => smart_proxies(:one)
    end
  end

  test "record should have dhcp attributes" do
    record = Net::DhcpRecord.new(:name => "test", :mac => "aa:bb:cc:dd:ee:ff",
                                 :network => "127.0.0.0", :ip => "127.0.0.1", "proxy" => smart_proxies(:one))
    assert_equal({:name => "test", :mac => "aa:bb:cc:dd:ee:ff",:network => "127.0.0.0", :ip => "127.0.0.1"}, record.send(:attrs))

  end

  test "record should be equal if their attrs are the same" do
    record1 = Net::DhcpRecord.new(:name => "test", :mac => "aa:bb:cc:dd:ee:ff",
                                 :network => "127.0.0.0", :ip => "127.0.0.1", "proxy" => smart_proxies(:one))
    record2 = Net::DhcpRecord.new(:name => "test", :mac => "aa:bb:cc:dd:ee:ff",
                                 :network => "127.0.0.0", :ip => "127.0.0.1", "proxy" => smart_proxies(:one))
    assert_equal record1, record2
  end

end
