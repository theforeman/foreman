require 'test_helper'

class NicBMCJailTest < ActiveSupport::TestCase
  def test_jail_should_include_these_methods
    allowed = [:provider, :username, :password]

    allowed.each do |m|
      assert Nic::BMC::Jail.allowed?(m), "Method #{m} is not available in Nic::BMC::Jail while should be allowed."
    end
  end
end
