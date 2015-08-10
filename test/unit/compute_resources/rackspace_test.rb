require 'test_helper'
require 'unit/compute_resources/compute_resource_test_helpers'

class RackspaceTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :ip => '10.0.0.154')
    cr = FactoryGirl.build(:rackspace_cr)
    iface = mock('iface1', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
    assert_equal host, as_admin { cr.associated_host(iface) }
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::Rackspace.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end

    it "raises RecordNotFound when the compute raises rackspace error" do
      cr = mock_cr_servers(Foreman::Model::Rackspace.new, servers_raising_exception(Fog::Compute::Rackspace::Error))
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end
end
