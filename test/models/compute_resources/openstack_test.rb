require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

module Foreman
  module Model
    class OpenstackTest < ActiveSupport::TestCase
      include ComputeResourceTestHelpers

      should have_one(:key_pair).with_foreign_key('compute_resource_id').
        dependent(:destroy)

      should validate_presence_of(:url)
      should validate_presence_of(:user)
      should validate_presence_of(:password)

      setup do
        @compute_resource = FactoryBot.build_stubbed(:openstack_cr)
      end

      teardown do
        Fog.unmock!
      end

      describe "url_for_fog" do
        it "parses the hostname and port" do
          @compute_resource = FactoryBot.build_stubbed(:openstack_cr)
          @compute_resource.url = 'http://stack.example.com:5000/v3/auth/tokens'
          assert_equal 'http://stack.example.com:5000', @compute_resource.send(:url_for_fog)

          @compute_resource.url = 'http://stack.example.com:5000/identity/v3/auth/tokens'
          assert_equal 'http://stack.example.com:5000/identity', @compute_resource.send(:url_for_fog)

          @compute_resource.url = 'http://stack.example.com:5000/identity/v2/auth/tokens'
          assert_equal 'http://stack.example.com:5000/identity', @compute_resource.send(:url_for_fog)

          @compute_resource.url = 'http://stack.example.com/identity/v3/auth/tokens'
          assert_equal 'http://stack.example.com:80/identity', @compute_resource.send(:url_for_fog)

          @compute_resource.url = 'http://stack.example.com/auth/tokens'
          assert_equal 'http://stack.example.com:80', @compute_resource.send(:url_for_fog)
        end
      end

      test "#associated_host matches any NIC" do
        host = FactoryBot.create(:host, :ip => '10.0.0.154')
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
                :scheduler_hint_value => "some-uuid",
              },
          }
          desired = {
            :os_scheduler_hints => {
              :group => "some-uuid",
            },
          }
          @compute_resource.format_scheduler_hint_filter(args)
          assert_equal(desired, args)
        end

        it "formats well when set to ServerGroupAffinity" do
          args = {
            :scheduler_hint_filter => "ServerGroupAffinity",
              :scheduler_hint_data => {
                :scheduler_hint_value => "some-uuid",
              },
          }
          desired = {
            :os_scheduler_hints => {
              :group => "some-uuid",
            },
          }
          @compute_resource.format_scheduler_hint_filter(args)
          assert_equal(desired, args)
        end

        it "formats well when set to Raw" do
          args = {
            :scheduler_hint_filter => "Raw",
              :scheduler_hint_data => {
                :scheduler_hint_value => '{"key": "value"}',
              },
          }
          desired = {
            :os_scheduler_hints => {
              'key' => "value",
            },
          }
          @compute_resource.format_scheduler_hint_filter(args)
          assert_equal(desired, args)
        end

        it "Should raise exception if set to Raw and malformed json" do
          args = {
            :scheduler_hint_filter => "Raw",
              :scheduler_hint_data => {
                :scheduler_hint_value => '{"key": }',
              },
          }
          assert_raise ::JSON::ParserError do
            @compute_resource.format_scheduler_hint_filter(args)
          end
        end

        it "Should raise exception if no hint data provided" do
          args = {
            :scheduler_hint_filter => "Raw",
          }
          e = assert_raise(::Foreman::Exception) do
            @compute_resource.format_scheduler_hint_filter(args)
          end
          assert_equal("ERF42-4598 [Foreman::Exception]: Hint data is missing", e.message)
        end
      end

      describe "find_vm_by_uuid" do
        it "raises RecordNotFound when the vm does not exist" do
          cr = mock_cr_servers(Foreman::Model::Openstack.new, empty_servers)
          assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
        end
      end

      describe '#normalize_vm_attrs' do
        let(:base_cr) { FactoryBot.build(:openstack_cr) }
        let(:cr) do
          mock_cr(base_cr,
            :security_groups => [
              stub(:id => 'grp1', :name => 'group 1'),
              stub(:id => 'grp2', :name => 'group 2'),
            ],
            :tenants => [
              stub(:id => 'tn1', :name => 'tenant 1'),
              stub(:id => 'tn2', :name => 'tenant 2'),
            ],
            :flavors => [
              stub(:id => 'flvr1', :name => 'flavour 1'),
              stub(:id => 'flvr2', :name => 'flavour 2'),
            ],
            :internal_networks => [
              stub(:id => 'nic1', :name => 'default'),
              stub(:id => 'nic2', :name => 'bridge'),
            ]
          )
        end

        test "passes neutron nics hash" do
          args = {
            :nics => [
              'nic1',
              {'net_id' => 'nic2', 'v4_fixed_ip' => '10.1.1.1'},
            ],
            'flavor_ref' => 'foo_flavor',
            'image_ref' => 'foo_image',
          }
          desired = {
            :nics => [
              {'net_id' => 'nic1'},
              {'net_id' => 'nic2', 'v4_fixed_ip' => '10.1.1.1'},
            ],
            'flavor_ref' => 'foo_flavor',
            'image_ref' => 'foo_image',
          }

          Fog.mock!
          @compute_resource.stubs(:key_pair).returns(mocked_key_pair)
          @compute_resource.create_vm(args)
          assert_equal(desired, args)
        end

        test 'maps flavor_ref to flavor_id' do
          assert_attrs_mapped(cr, 'flavor_ref', 'flavor_id')
        end

        test 'finds flavor_name' do
          vm_attrs = {
            'flavor_ref' => 'flvr1',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal('flavour 1', normalized['flavor_name'])
        end

        test 'sets blank availability_zone to nil' do
          assert_blank_attr_nilified(cr, 'availability_zone')
        end

        test 'sets blank tenant_id to nil' do
          assert_blank_attr_nilified(cr, 'tenant_id')
        end

        test 'finds tenant_name' do
          vm_attrs = {
            'tenant_id' => 'tn1',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal('tenant 1', normalized['tenant_name'])
        end

        test 'maps security_groups to security_group_name' do
          assert_attrs_mapped(cr, 'security_groups', 'security_group_name')
        end

        test 'sets blank security_group_name to nil' do
          assert_blank_mapped_attr_nilified(cr, 'security_groups', 'security_group_name')
        end

        test 'finds security_group_id' do
          vm_attrs = {
            'security_groups' => 'group 2',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal('grp2', normalized['security_group_id'])
        end

        test 'maps network to floating_ip_network' do
          assert_attrs_mapped(cr, 'network', 'floating_ip_network')
        end

        test 'nilifies floating_ip_network when network is blank' do
          assert_blank_mapped_attr_nilified(cr, 'network', 'floating_ip_network')
        end

        test 'casts boot_from_volume to boolean' do
          vm_attrs = {
            'boot_from_volume' => 'true',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal(true, normalized['boot_from_volume'])
        end

        test 'translates boot_volume_size to bytes' do
          vm_attrs = {
            'size_gb' => '2',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal(2.gigabyte.to_s, normalized['boot_volume_size'])
        end

        test 'maps zero (default) boot_volume_size nil' do
          vm_attrs = {
            'size_gb' => '0',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_nil(normalized['boot_volume_size'])
        end

        test 'normalizes nics_attributes' do
          vm_attrs = {
            'nics' => ['', 'nic1', 'nic2'],
          }
          expected_attrs = {
            '0' => {
              'id' => 'nic1',
              'name' => 'default',
            },
            '1' => {
              'id' => 'nic2',
              'name' => 'bridge',
            },
          }

          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal(expected_attrs, normalized['interfaces_attributes'])
        end

        test 'nilifies blank scheduler_hint_filter' do
          assert_blank_attr_nilified(cr, 'scheduler_hint_filter')
        end

        test 'image_ref is mapped to image_id' do
          assert_attrs_mapped(cr, 'image_ref', 'image_id')
        end

        describe 'images' do
          let(:base_cr) { FactoryBot.create(:openstack_cr, :with_images) }

          test 'adds image name' do
            vm_attrs = {
              'image_ref' => cr.images.last.uuid,
            }
            normalized = cr.normalize_vm_attrs(vm_attrs)

            assert_equal(cr.images.last.name, normalized['image_name'])
          end

          test 'leaves image name empty when image_ref is nil' do
            vm_attrs = {
              'image_ref' => nil,
            }
            normalized = cr.normalize_vm_attrs(vm_attrs)

            assert(normalized.has_key?('image_name'))
            assert_nil(normalized['image_name'])
          end

          test "leaves image name empty when image wasn't found" do
            vm_attrs = {
              'image_ref' => 'unknown',
            }
            normalized = cr.normalize_vm_attrs(vm_attrs)

            assert(normalized.has_key?('image_name'))
            assert_nil(normalized['image_name'])
          end
        end

        test 'correctly fills empty attributes' do
          normalized = cr.normalize_vm_attrs({})
          expected_attrs = {
            'availability_zone' => nil,
            'tenant_id' => nil,
            'tenant_name' => nil,
            'boot_from_volume' => nil,
            'scheduler_hint_filter' => nil,
            'flavor_id' => nil,
            'flavor_name' => nil,
            'security_group_name' => nil,
            'security_group_id' => nil,
            'floating_ip_network' => nil,
            'boot_volume_size' => nil,
            'interfaces_attributes' => {},
            'image_id' => nil,
            'image_name' => nil,
          }

          assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
          assert_equal(expected_attrs, normalized)
        end

        test 'attribute names' do
          check_vm_attribute_names(cr)
        end
      end

      private

      def mocked_key_pair
        key_pair = mock
        key_pair.stubs(:name).returns('foo_key')
        key_pair
      end
    end
  end
end
