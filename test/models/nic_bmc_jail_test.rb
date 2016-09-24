require 'test_helper'

class NicBMCJailTest < ActiveSupport::TestCase
  def test_jail_should_include_these_methods
    allowed = [:provider, :username, :password]

    allowed.each do |m|
      assert Nic::BMC::Jail.allowed?(m), "Method #{m} is not available in Nic::BMC::Jail while should be allowed."
    end
  end

  def test_jail_should_not_include_these_methods
    denied = [:password_redacted]

    denied.each do |m|
      refute Nic::BMC::Jail.allowed?(m), "Method #{m} is available in Nic::BMC::Jail while should not be allowed."
    end
  end
end
