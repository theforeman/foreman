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

  describe "formatting hints" do
    it "formats well when set to ServerGroupAntiAffinity" do
      args = {
          :scheduler_hint_filter => "ServerGroupAntiAffinity",
          :scheduler_hint_data => {
              :scheduler_hint_value => "some-uuid"
          }
      }
      desired = {
          :os_scheduler_hints => {
              :group => "some-uuid"
          }
      }
      @compute_resource.format_scheduler_hint_filter(args)
      assert_equal(desired, args)
    end

    it "formats well when set to ServerGroupAffinity" do
      args = {
          :scheduler_hint_filter => "ServerGroupAffinity",
          :scheduler_hint_data => {
              :scheduler_hint_value => "some-uuid"
          }
      }
      desired = {
          :os_scheduler_hints => {
              :group => "some-uuid"
          }
      }
      @compute_resource.format_scheduler_hint_filter(args)
      assert_equal(desired, args)
    end

    it "formats well when set to Raw" do
      args = {
          :scheduler_hint_filter => "Raw",
          :scheduler_hint_data => {
              :scheduler_hint_value => '{"key": "value"}'
          }
      }
      desired = {
          :os_scheduler_hints => {
              'key' => "value"
          }
      }
      @compute_resource.format_scheduler_hint_filter(args)
      assert_equal(desired, args)
    end

    it "Should raise exception if set to Raw and malformed json" do
      args = {
          :scheduler_hint_filter => "Raw",
          :scheduler_hint_data => {
              :scheduler_hint_value => '{"key": }'
          }
      }
      assert_raise ::JSON::ParserError do
        @compute_resource.format_scheduler_hint_filter(args)
      end
    end

    it "Should raise exception if no hint data provided" do
      args = {
          :scheduler_hint_filter => "Raw",
      }
      e = assert_raise(::RuntimeError)  do
        @compute_resource.format_scheduler_hint_filter(args)
      end
      assert_equal("Hint data is missing", e.message)
    end
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
