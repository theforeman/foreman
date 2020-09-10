require 'test_helper'
require 'net'

class NetTest < ActiveSupport::TestCase
  test "Net record should auto assign attributes" do
    record = Net::Record.new :hostname => "test", "proxy" => smart_proxies(:one)
    assert_equal "test", record.hostname
  end

  test "should have a logger" do
    record = Net::Record.new :hostname => "test", "proxy" => smart_proxies(:one)
    assert_not_nil record.logger
  end

  test "should default logger to rails logger" do
    record = Net::Record.new :hostname => "test", "proxy" => smart_proxies(:one)
    assert_equal logger, record.logger
  end
end
