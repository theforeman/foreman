require 'test_helper'
require 'unit/compute_resources/compute_resource_test_helpers'

class LibvirtTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:libvirt_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    assert_equal host, as_admin { cr.associated_host(iface) }
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::Libvirt.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end

    it "raises RecordNotFound when the compute raises retrieve error" do
      cr = mock_cr_servers(Foreman::Model::Libvirt.new, servers_raising_exception(Libvirt::RetrieveError))
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end

  describe "compute_attributes_for" do
    test "returns memory in bytes" do
      vm = mock()
      vm.stubs(:attributes).returns({ :memory_size => 6 })

      cr = FactoryGirl.build(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_equal 6*1024, attrs[:memory]
    end

    test "returns nil memory when :memory_size is not provided" do
      vm = mock()
      vm.stubs(:attributes).returns({})

      cr = FactoryGirl.build(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_equal nil, attrs[:memory]
    end
  end
end
