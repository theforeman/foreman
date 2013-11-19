require 'test_helper'

class DnsOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  def test_system_should_have_dns
    if unattended?
      h = systems(:one)
      assert h.valid?
      assert h.dns?
      assert h.reverse_dns?
      assert_not_nil h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end

  def test_system_should_have_dns_but_not_ptr
    if unattended?
      h = systems(:one)
      h.subnet = nil
      assert h.valid?
      assert h.dns?
      assert !h.reverse_dns?
      assert_not_nil h.dns_a_record
      assert_nil h.dns_ptr_record
    end
  end

  def test_system_should_not_have_dns
    if unattended?
      h = systems(:minimal)
      assert h.valid?
      assert !h.dns?
      assert !h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_equal nil, h.dns_ptr_record
    end
  end

  def test_system_should_not_have_dns_but_should_have_ptr
    if unattended?
      h = systems(:minimal)
      h.subnet = subnets(:one)
      h.managed = true
      assert h.valid?
      assert !h.dns?
      assert h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end
end
