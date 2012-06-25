ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def logger
    Rails.logger
  end

  class Test::Unit::TestCase
    include RR::Adapters::TestUnit
  end

  def set_session_user
    SETTINGS[:login] ? {:user => User.find_by_login("admin").id, :expires_at => 5.minutes.from_now} : {}
  end

  def as_user user
    saved_user   = User.current
    User.current = users(user)
    result = yield
    User.current = saved_user
    result
  end

  def as_admin
    saved_user   = User.current
    User.current = users(:admin)
    result = yield
    User.current = saved_user
    result
  end

  def unattended?
    SETTINGS[:unattended].nil? or SETTINGS[:unattended]
  end

  def self.disable_orchestration
    #This disables the DNS/DHCP orchestration
    Host.any_instance.stubs(:boot_server).returns("boot_server")
    Resolv::DNS.any_instance.stubs(:getname).returns("foo.fqdn")
    Resolv::DNS.any_instance.stubs(:getaddress).returns("127.0.0.1")
    Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(false)
    Net::DNS::PTRRecord.any_instance.stubs(:conflicting?).returns(false)
    Net::DHCP::Record.any_instance.stubs(:create).returns(true)
    Net::DHCP::SparcRecord.any_instance.stubs(:create).returns(true)
    Net::DHCP::Record.any_instance.stubs(:conflicting?).returns(false)
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["production"])
  end

  def disable_orchestration
    ActiveSupport::TestCase.disable_orchestration
  end
end
