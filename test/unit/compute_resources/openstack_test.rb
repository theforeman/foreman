require 'test_helper'

class OpenstackTest < ActiveSupport::TestCase
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

  private

  def mocked_key_pair
    key_pair = mock
    key_pair.stubs(:name).returns('foo_key')
    key_pair
  end
end
