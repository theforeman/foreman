require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_dhcp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dhcp != nil
      assert h.dhcp?
    end
  end

  def test_host_should_not_have_dhcp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal h.dhcp, nil
      assert_equal h.dhcp?, false
    end
  end
end
