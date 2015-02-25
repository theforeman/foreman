require 'test_helper'

class DnsOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
  end

  def test_host_should_have_dns
    if unattended?
      h = FactoryGirl.create(:host, :with_dns_orchestration)
      assert h.valid?
      assert h.dns?
      assert h.reverse_dns?
      assert_not_nil h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end

  def test_host_should_have_dns_but_not_ptr
    if unattended?
      h = FactoryGirl.build(:host, :with_dns_orchestration)
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
      h = FactoryGirl.create(:host)
      assert h.valid?
      assert !h.dns?
      assert !h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_equal nil, h.dns_ptr_record
    end
  end

  def test_host_should_not_have_dns_but_should_have_ptr
    if unattended?
      h = FactoryGirl.build(:host, :with_dns_orchestration)
      h.domain.dns = nil
      assert h.valid?
      assert !h.dns?
      assert h.reverse_dns?
      assert_equal nil, h.dns_a_record
      assert_not_nil h.dns_ptr_record
    end
  end

  def test_bmc_should_have_valid_dns_records
    if unattended?
      h = FactoryGirl.create(:host, :with_dns_orchestration)
      b = FactoryGirl.create(:nic_bmc, :host => h,
                             :domain => domains(:mydomain),
                             :subnet => subnets(:five),
                             :name => h.shortname,
                             :ip => '10.0.0.3')
      assert b.dns?
      assert b.reverse_dns?
      assert_equal "#{b.shortname}.#{b.domain.name}/#{b.ip}", b.dns_a_record.to_s
      assert_equal "#{b.ip}/#{b.shortname}.#{b.domain.name}", b.dns_ptr_record.to_s
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:ip_available?).never
      assert h.valid?
      assert_equal false, h.dns?
      assert_equal false, h.reverse_dns?
    end
  end
end
