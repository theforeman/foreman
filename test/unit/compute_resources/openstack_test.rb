require 'test_helper'
require 'unit/compute_resources/compute_resource_test_helpers'

class OpenstackTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  setup do
    @compute_resource = FactoryGirl.build(:openstack_cr)
  end

  teardown do
    Fog.unmock!
  end

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :ip => '10.0.0.154')
    iface = mock('iface1', :floating_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
    assert_equal host, as_admin { @compute_resource.associated_host(iface) }
  end

  test "boot_from_volume does not get triggered when a string 'false' is passed as argument" do
    Fog.mock!
    @compute_resource.stubs(:key_pair).returns(mocked_key_pair)
    @compute_resource.expects(:boot_from_volume).never
    @compute_resource.create_vm(:boot_from_volume => 'false', :nics => [""],
                                :flavor_ref => 'foo_flavor', :image_ref => 'foo_image')
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::Openstack.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end

  private

  def mocked_key_pair
    key_pair = mock
    key_pair.stubs(:name).returns('foo_key')
    key_pair
  end
end
