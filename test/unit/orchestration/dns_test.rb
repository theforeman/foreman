require 'test_helper'

class DnsOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  def test_host_should_have_dns
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dns?
      assert h.reverse_dns?
      assert_not_nil h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end

  def test_host_should_have_dns_but_not_ptr
    if unattended?
      h = hosts(:one)
      h.subnet = nil
      assert h.valid?
      assert h.dns?
      assert !h.reverse_dns?
      assert_not_nil h.dns_a_record
      assert_nil h.dns_ptr_record
    end
  end

  def test_host_should_not_have_dns
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert !h.dns?
      assert !h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_equal nil, h.dns_ptr_record
    end
  end

  def test_host_should_not_have_dns_but_should_have_ptr
    if unattended?
      h = hosts(:minimal)
      h.subnet = subnets(:one)
      h.managed = true
      assert h.valid?
      assert !h.dns?
      assert h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end

  def test_bmc_should_have_valid_dns_records
    if unattended?
      b = nics(:bmc)
      b.domain = domains(:mydomain)
      b.subnet = subnets(:five)
      assert b.dns?
      assert b.reverse_dns?
      assert_equal "#{b.name}.#{b.domain.name}/#{b.ip}", b.dns_a_record.to_s
      assert_equal "#{b.ip}/#{b.name}.#{b.domain.name}", b.dns_ptr_record.to_s
    end
  end
end
