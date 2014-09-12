require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
  end

  test 'host_should_have_dhcp' do
    if unattended?
      h = FactoryGirl.create(:host, :with_dhcp_orchestration)
      assert h.valid?
      assert h.dhcp?, 'host.dhcp? does not return true'
      assert_instance_of Net::DHCP::Record, h.dhcp_record
    end
  end

  test 'host_should_not_have_dhcp' do
    if unattended?
      h = FactoryGirl.create(:host)
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  def test_bmc_should_have_valid_dhcp_record
    if unattended?
      h = FactoryGirl.create(:host, :with_dhcp_orchestration)
      b = nics(:bmc)
      b.host   = h
      b.domain = domains(:mydomain)
      b.subnet = subnets(:five)
      assert b.dhcp?
      assert_equal "#{b.name}.#{b.domain.name}-#{b.mac}/#{b.ip}", b.dhcp_record.to_s
    end
  end

  test "jumpstart parameter generation" do
    h = FactoryGirl.create(:host, :managed,
        :ip => '2.3.4.10',
        :architecture => architectures(:sparc),
        :operatingsystem => operatingsystems(:solaris10),
        :subnet => subnets(:one),
        :domain => domains(:yourdomain),
        :compute_resource => compute_resources(:one),
        :model => models(:V210),
        :medium => media(:solaris10),
        :puppet_proxy => smart_proxies(:puppetmaster),
        :ptable => ptables(:one)
        )
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    result = h.os.jumpstart_params h, h.model.vendor_class
    assert_equal result, {
      :vendor                => "<Sun-Fire-V210>",
      :install_path          => "/vol/solgi_5.10/sol10_hw0910_sparc",
      :install_server_ip     => "2.3.4.5",
      :install_server_name   => "brsla01",
      :jumpstart_server_path => "2.3.4.5:/vol/jumpstart",
      :root_path_name        => "/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot",
      :root_server_hostname  => "brsla01",
      :root_server_ip        => "2.3.4.5",
      :sysid_server_path     => "2.3.4.5:/vol/jumpstart/sysidcfg/sysidcfg_primary"
    }
  end

  test "new host should create a dhcp reservation" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration)
    assert h.new_record?

    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action.last == :set_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
  end

  test "new host should create a BMC dhcp reservation" do
    h = FactoryGirl.build(:host, :with_dhcp_orchestration, :name => 'dummy-123')
    assert h.new_record?
    h.interfaces_attributes = [{ :name => "dummy-bmc", :ip => h.ip.succ, :mac => "aa:bb:cd:cd:ee:ff",
                                 :subnet_id => h.subnet_id, :provider => 'IPMI', :type => 'Nic::BMC', :domain_id => h.domain_id}]
    assert h.valid?

    bmc = h.interfaces.detect { |i| i.name == 'dummy-bmc' }

    host_tasks      = h.queue.items.select { |t| t.action.first == h }
    interface_tasks = h.queue.items.select { |t| t.action.first == bmc }

    assert_equal 1, host_tasks.select { |t| t.action.last == :set_dhcp }.size
    assert_empty host_tasks.select { |t| t.action.last == :del_dhcp }
    assert_equal 1, interface_tasks.select { |t| t.action.last == :set_dhcp }.size
    assert_empty interface_tasks.select  { |t| t.action.last == :del_dhcp }
  end

  test "when an existing host change its ip address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.ip = h.ip.succ
    assert h.valid?
    # 1st creation, 2nd update
    assert_equal 2, h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size
    assert_equal 1, h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size
  end

  test "when an existing host change its bmc ip address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create!(:host_id => h.id, :mac => "da:aa:aa:ab:db:bb", :domain_id => h.domain_id,
                       :ip => h.ip.succ, :subnet_id => h.subnet_id, :name => "bmc-#{h}", :provider => 'IPMI')
    end
    h.reload
    bmc = h.interfaces.bmc.first
    bmc.ip = bmc.ip.succ
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc, :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

  test "when an existing host change its mac address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    h.mac = h.mac.succ
    assert h.valid?
    assert_equal 2, h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size
    assert_equal 1, h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create! :host => h, :mac => "aa:aa:aa:ab:bd:bb", :ip => h.ip.succ, :domain => h.domain,
                       :subnet => h.subnet, :name => "bmc1-#{h}", :provider => 'IPMI'
    end
    h.reload
    bmc = h.interfaces.bmc.first
    bmc.mac = bmc.mac.succ
    assert h.valid?
    assert bmc.valid?
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = FactoryGirl.create(:host, :with_dhcp_orchestration)
    as_admin do
      Nic::BMC.create!(:host => h, :mac => "aa:aa:ad:ab:bb:bb", :domain => h.domain, :subnet => h.subnet,
                       :name => "bmc-it", :provider => 'IPMI', :ip => h.ip.succ)
    end
    h.reload
    h.mac = h.mac.succ
    bmc = h.interfaces.bmc.first
    assert !bmc.new_record?
    bmc.mac = bmc.mac.succ
    assert h.valid?
    assert bmc.valid?
    assert_equal 2, h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size
    assert_equal 1, h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc,     :set_dhcp ] }.size
    assert_equal 1, bmc.queue.items.select {|x| x.action == [ bmc.old, :del_dhcp ] }.size
  end

end
