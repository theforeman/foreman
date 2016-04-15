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
      assert_not_nil h.dns_record(:a)
      assert_not_nil h.dns_record(:ptr4)
    end
  end

  def test_host_should_have_dns6
    if unattended?
      h = FactoryGirl.create(:host, :with_ipv6_dns_orchestration)
      assert h.valid?
      assert h.dns6?
      assert h.reverse_dns6?
      assert_not_nil h.dns_record(:aaaa)
      assert_not_nil h.dns_record(:ptr6)
    end
  end

  def test_host_should_have_dns_but_not_ptr
    if unattended?
      h = FactoryGirl.build(:host, :with_dns_orchestration)
      h.subnet = nil
      assert h.valid?
      assert h.dns?
      assert !h.reverse_dns?
      assert_not_nil h.dns_record(:a)
      assert_nil h.dns_record(:ptr4)
    end
  end

  def test_host_should_not_have_dns
    if unattended?
      h = FactoryGirl.create(:host)
      assert h.valid?
      assert !h.dns?
      assert !h.reverse_dns?
      assert_equal nil, h.dns_record(:a)
      assert_equal nil, h.dns_record(:ptr4)
    end
  end

  def test_host_should_not_have_dns_but_should_have_ptr
    if unattended?
      h = FactoryGirl.build(:host, :with_dns_orchestration)
      h.domain.dns = nil
      assert h.valid?
      assert !h.dns?
      assert h.reverse_dns?
      assert_equal nil, h.dns_record(:a)
      assert_not_nil h.dns_record(:ptr4)
    end
  end

  def test_bmc_should_have_valid_dns_records
    if unattended?
      h = FactoryGirl.create(:host, :with_dns_orchestration, :location => nil, :organization => nil)
      b = FactoryGirl.create(:nic_bmc, :host => h,
                             :domain => domains(:mydomain),
                             :subnet => subnets(:five),
                             :name => h.shortname,
                             :ip => '10.0.0.3')
      assert b.dns?
      assert b.reverse_dns?
      assert_equal "#{b.shortname}.#{b.domain.name}/#{b.ip}", b.dns_record(:a).to_s
      assert_equal "#{b.ip}/#{b.shortname}.#{b.domain.name}", b.dns_record(:ptr4).to_s
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:ip_available?).never
      assert h.valid?
      assert_equal false, h.dns?
      assert_equal false, h.reverse_dns?
      assert_equal false, h.dns6?
      assert_equal false, h.reverse_dns6?
    end
  end

  def test_should_rebuild_dns_with_ipv4
    h = FactoryGirl.create(:host, :with_dns_orchestration)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).returns(true)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).never
    assert h.interfaces.first.rebuild_dns
  end

  def test_should_rebuild_dns_with_ipv6
    h = FactoryGirl.create(:host, :with_ipv6_dns_orchestration)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:a).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).returns(true)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).returns(true)
    assert h.interfaces.first.rebuild_dns
  end

  def test_should_skip_dns_rebuild
    nic = FactoryGirl.build(:nic_managed)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:a).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4).never
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).never
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).never
    assert nic.rebuild_dns
  end

  def test_dns_rebuild_should_fail
    h = FactoryGirl.create(:host, :with_dns_orchestration)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).returns(false)
    refute h.interfaces.first.rebuild_dns
  end

  def test_dns_rebuild_should_fail_with_exception
    h = FactoryGirl.create(:host, :with_dns_orchestration)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
    Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
    Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
    Nic::Managed.any_instance.stubs(:recreate_dns_record).with(:ptr4).raises(StandardError, 'DNS test fail')
    refute h.interfaces.first.rebuild_dns
  end

  test 'test_host_should_error_timeout_error_properly' do
    if unattended?
      h = FactoryGirl.create(:host, :with_dns_orchestration, :location => nil, :organization => nil)
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(true)
      Net::DNS::ARecord.any_instance.stubs(:conflicts).raises(Net::Error)
      h.primary_interface.domain.stubs(:nameservers).returns(["1.2.3.4"])
      h.primary_interface.send(:dns_conflict_detected?)
      assert_match /^Error connecting .* DNS servers/, h.errors[:base].first
    end
  end

  test 'test_host_should_error_timeout_error_properly' do
    if unattended?
      h = FactoryGirl.create(:host, :with_dns_orchestration, :location => nil, :organization => nil)
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(true)
      Net::DNS::ARecord.any_instance.stubs(:conflicts).raises(Net::Error)
      h.primary_interface.domain.stubs(:nameservers).returns([])
      h.primary_interface.send(:dns_conflict_detected?)
      assert_match /^Error connecting to system DNS/, h.errors[:base].first
    end
  end

  test 'dns record should be nil for invalid ip' do
    host = FactoryGirl.build(:host, :with_dns_orchestration, :interfaces => [FactoryGirl.build(:nic_primary_and_provision, :ip => "aaaaaaa")])
    assert_nil host.dns_record(:ptr4)
    assert_nil host.dns_record(:a)
  end
end
