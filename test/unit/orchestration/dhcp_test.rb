require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  def test_host_should_have_dhcp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dhcp?
      assert_instance_of Net::DHCP::Record, h.dhcp_record
    end
  end

  def test_host_should_not_have_dhcp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  test "jumpstart parameter generation" do
    h = hosts(:sol10host)
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    #User.current = users(:admin)
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

  test "new host should create a dhcp reservertion" do
    h = hosts(:dhcp).clone
    assert h.new_record?
    h.name = "dummy-123"
    h.ip = "2.3.4.101"
    h.mac = "bb:bb:bb:bb:bb"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action.last == :set_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
  end

  test "new host should create a BMC dhcp reservertion" do
    h = hosts(:dhcp).clone
    assert h.new_record?
    h.name = "dummy-123"
    h.ip = "2.3.4.101"
    h.mac = "bb:bb:bb:bb:bb"
    h.sp_name = "dummy-bmc"
    h.sp_ip = "2.3.4.102"
    h.sp_mac = "aa:bb:cd:cd:ee:ff"
    h.sp_subnet = h.subnet
    assert h.valid?
    assert h.sp_dhcp?
    assert_equal h.queue.items.select {|x| x.action.last == :set_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_dhcp }.empty?
    assert_equal h.queue.items.select {|x| x.action.last == :set_sp_dhcp }.size, 1
    assert h.queue.items.select {|x| x.action.last == :del_sp_dhcp }.empty?
  end

  test "existing host should not change any dhcp settings" do
    h = hosts(:dhcp)
    assert h.valid?
    assert_equal h.ip, h.old.ip
    assert_equal h.mac, h.old.mac
    assert_equal h.name, h.old.name
    assert_equal h.subnet, h.old.subnet
    assert h.queue.items.empty?
  end

  test "existing host should not change any bmc dhcp settings" do
    h = hosts(:sp_dhcp)
    assert h.valid?
    assert_equal h.sp_ip, h.old.sp_ip
    assert_equal h.sp_mac, h.old.sp_mac
    assert_equal h.sp_name, h.old.sp_name
    assert_equal h.sp_subnet, h.old.sp_subnet
    assert h.queue.items.empty?
  end

  test "when an existing host change its ip address, its dhcp record should be updated" do
    h = hosts(:dhcp)
    h.ip = "2.3.4.101"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change its bmc ip address, its dhcp record should be updated" do
    h = hosts(:sp_dhcp)
    h.sp_ip = "2.3.4.101"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_sp_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_sp_dhcp ] }.size, 1
  end

  test "when an existing host change its mac address, its dhcp record should be updated" do
    h = hosts(:dhcp)
    h.mac = "aa:aa:aa:bb:bb:dd"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
  end

  test "when an existing host change its bmc mac address, its dhcp record should be updated" do
    h = hosts(:sp_dhcp)
    h.sp_mac = "aa:aa:aa:ab:bb:bb"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_sp_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_sp_dhcp ] }.size, 1
  end

  test "when an existing host change multiple attributes, both his dhcp and bmc dhcp records should be updated" do
    h = hosts(:sp_dhcp)
    h.mac = "aa:aa:aa:bb:bb:dd"
    h.sp_name = "BMC-it"
    assert h.valid?
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h,     :set_sp_dhcp ] }.size, 1
    assert_equal h.queue.items.select {|x| x.action == [ h.old, :del_sp_dhcp ] }.size, 1
  end

end
