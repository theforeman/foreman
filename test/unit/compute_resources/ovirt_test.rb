require 'test_helper'
require 'unit/compute_resources/compute_resource_test_helpers'

class OvirtTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:ovirt_cr)
    iface1 = mock('iface1', :mac => '36:48:c5:c9:86:f2')
    iface2 = mock('iface2', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::Ovirt.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end

    it "raises RecordNotFound when the compute raises retrieve error" do
      cr = mock_cr_servers(Foreman::Model::Ovirt.new, servers_raising_exception(OVIRT::OvirtException.new('VM not found')))
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end
end
