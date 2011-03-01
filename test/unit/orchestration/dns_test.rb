require 'test_helper'

class DnsOrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_dns
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dns != nil
      assert h.dns?
    end
  end

  def test_host_should_not_have_dns
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal h.dns, nil
      assert_equal h.dns?, false
    end
  end
end
