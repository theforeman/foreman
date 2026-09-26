require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

module Foreman
  module Model
    class OpenstackTest < ActiveSupport::TestCase
      include ComputeResourceTestHelpers

      should have_one(:key_pair).with_foreign_key('compute_resource_id').
        dependent(:destroy)

      should validate_presence_of(:url)
      should validate_presence_of(:password)

      setup do
        @compute_resource = FactoryBot.build_stubbed(:openstack_cr)
      end

      teardown do
        Fog.unmock!
      end

      test "defaults to username and password authentication" do
        assert_equal Openstack::PASSWORD_AUTHENTICATION, @compute_resource.authentication_type
        assert @compute_resource.password_authentication?
        assert_not @compute_resource.application_credentials?
      end

      test "requires a username for password authentication" do
        @compute_resource.user = nil

        assert_not @compute_resource.valid?
        assert_includes @compute_resource.errors[:user], "can't be blank"
      end

      test "accepts application credentials without a username" do
        use_application_credentials(@compute_resource)
        @compute_resource.user = nil

        assert @compute_resource.valid?
      end

      test "requires an Application Credential ID" do
        use_application_credentials(@compute_resource)
        @compute_resource.application_credential_id = nil

        assert_not @compute_resource.valid?
        assert_includes @compute_resource.errors[:application_credential_id], "can't be blank"
      end

      test "requires Keystone v3 for application credentials" do
        use_application_credentials(@compute_resource)
        @compute_resource.url = 'http://openstack.example.com/v2.0'

        assert_not @compute_resource.valid?
        assert_includes @compute_resource.errors[:authentication_type], "requires a Keystone v3 URL"
      end

      test "requires a new secret when changing authentication type" do
        compute_resource = FactoryBot.create(:openstack_cr)
        compute_resource.url = 'http://openstack.example.com/v3/auth/tokens'
        compute_resource.authentication_type = Openstack::APPLICATION_CREDENTIAL_AUTHENTICATION
        compute_resource.application_credential_id = 'credential-id'

        assert_not compute_resource.valid?
        assert_includes compute_resource.errors[:password], "must be changed when the authentication type changes"

        compute_resource.application_credential_secret = 'application-secret'
        assert compute_resource.valid?
      end

      test "uses username credentials for fog by default" do
        credentials = @compute_resource.send(:fog_credentials)

        assert_equal 'osuser', credentials[:openstack_username]
        assert_equal 'ospassword', credentials[:openstack_api_key]
        assert_not credentials.key?(:openstack_application_credential_id)
        assert_not credentials.key?(:openstack_application_credential_secret)
      end

      test "uses Application Credentials for fog without username credentials" do
        use_application_credentials(@compute_resource)

        credentials = @compute_resource.send(:fog_credentials)

        assert_equal 'credential-id', credentials[:openstack_application_credential_id]
        assert_equal 'application-secret', credentials[:openstack_application_credential_secret]
        assert_not credentials.key?(:openstack_username)
        assert_not credentials.key?(:openstack_api_key)
      end

      test "does not log the Application Credential secret" do
        use_application_credentials(@compute_resource)
        output = StringIO.new
        @compute_resource.stubs(:logger).returns(ActiveSupport::Logger.new(output))

        @compute_resource.send(:fog_credentials)

        assert_includes output.string, 'credential-id'
        assert_not_includes output.string, 'application-secret'
      end

      test "stores the Application Credential secret encrypted" do
        compute_resource = FactoryBot.build(:openstack_cr)
        compute_resource.stubs(:encryption_key).returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
        use_application_credentials(compute_resource)

        compute_resource.save!

        assert_equal 'application-secret', compute_resource.reload.password
        assert_not_equal 'application-secret', compute_resource.password_in_db
      end

      test "uses the project scoped by Application Credentials without listing user projects" do
        use_application_credentials(@compute_resource)
        project = { 'id' => 'project-id', 'name' => 'project-name' }
        identity_client = mock
        identity_client.expects(:current_tenant).returns(project)
        identity_client.expects(:list_user_projects).never
        projects_collection = mock
        projects_collection.expects(:new).with(project).returns(
          OpenStruct.new(:id => 'project-id', :name => 'project-name')
        )
        identity_client.expects(:projects).returns(projects_collection)
        @compute_resource.stubs(:identity_client).returns(identity_client)

        projects = @compute_resource.tenants

        assert_equal ['project-id'], projects.map(&:id)
        assert_equal ['project-name'], projects.map(&:name)
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

      test "process_fixed_ips adds fixed IP when interface has IP specified" do
        args = {
          :nics => [{ 'net_id' => 'network-123' }],
          :interfaces_attributes => {
            '0' => { 'ip' => '192.168.1.100' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [{ 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100' }]
        assert_equal expected_nics, args[:nics]
        assert_nil args[:interfaces_attributes]
      end

      test "process_fixed_ips handles multiple networks correctly" do
        args = {
          :nics => [
            { 'net_id' => 'network-123' },
            { 'net_id' => 'network-456' },
          ],
          :interfaces_attributes => {
            '0' => { 'ip' => '192.168.1.100' },
            '1' => { 'ip' => '10.0.0.50' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [
          { 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100' },
          { 'net_id' => 'network-456', 'v4_fixed_ip' => '10.0.0.50' },
        ]
        assert_equal expected_nics, args[:nics]
      end

      test "process_fixed_ips handles out-of-order interface indices" do
        args = {
          :nics => [
            { 'net_id' => 'network-123' },
            { 'net_id' => 'network-456' },
          ],
          :interfaces_attributes => {
            '1' => { 'ip' => '10.0.0.50' },
            '0' => { 'ip' => '192.168.1.100' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [
          { 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100' },
          { 'net_id' => 'network-456', 'v4_fixed_ip' => '10.0.0.50' },
        ]
        assert_equal expected_nics, args[:nics]
      end

      test "process_fixed_ips adds IPv6 address when interface has IPv6 specified" do
        args = {
          :nics => [{ 'net_id' => 'network-123' }],
          :interfaces_attributes => {
            '0' => { 'ip6' => '2001:db8::1' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [{ 'net_id' => 'network-123', 'v6_fixed_ip' => '2001:db8::1' }]
        assert_equal expected_nics, args[:nics]
        assert_nil args[:interfaces_attributes]
      end

      test "process_fixed_ips adds both IPv4 and IPv6 addresses" do
        args = {
          :nics => [{ 'net_id' => 'network-123' }],
          :interfaces_attributes => {
            '0' => { 'ip' => '192.168.1.100', 'ip6' => '2001:db8::1' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [{ 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100', 'v6_fixed_ip' => '2001:db8::1' }]
        assert_equal expected_nics, args[:nics]
        assert_nil args[:interfaces_attributes]
      end

      test "process_fixed_ips handles multiple networks with mixed IPv4 and IPv6" do
        args = {
          :nics => [
            { 'net_id' => 'network-123' },
            { 'net_id' => 'network-456' },
          ],
          :interfaces_attributes => {
            '0' => { 'ip' => '192.168.1.100', 'ip6' => '2001:db8::1' },
            '1' => { 'ip' => '10.0.0.50', 'ip6' => '2001:db8::2' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [
          { 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100', 'v6_fixed_ip' => '2001:db8::1' },
          { 'net_id' => 'network-456', 'v4_fixed_ip' => '10.0.0.50', 'v6_fixed_ip' => '2001:db8::2' },
        ]
        assert_equal expected_nics, args[:nics]
      end

      test "process_fixed_ips skips nics without net_id" do
        args = {
          :nics => [
            { 'net_id' => 'network-123' },
            { 'other_key' => 'value' },
            { 'net_id' => 'network-456' },
          ],
          :interfaces_attributes => {
            '0' => { 'ip' => '192.168.1.100' },
            '1' => { 'ip' => '10.0.0.50' },
            '2' => { 'ip' => '172.16.0.1' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [
          { 'net_id' => 'network-123', 'v4_fixed_ip' => '192.168.1.100' },
          { 'other_key' => 'value' },
          { 'net_id' => 'network-456', 'v4_fixed_ip' => '10.0.0.50' },
        ]
        assert_equal expected_nics, args[:nics]
      end

      test "process_fixed_ips handles empty IP values gracefully" do
        args = {
          :nics => [{ 'net_id' => 'network-123' }],
          :interfaces_attributes => {
            '0' => { 'ip' => '', 'ip6' => '' },
          },
        }

        @compute_resource.send(:process_fixed_ips, args)

        expected_nics = [{ 'net_id' => 'network-123' }]
        assert_equal expected_nics, args[:nics]
        assert_nil args[:interfaces_attributes]
      end

      test "create_vm processes fixed IPs when interfaces_attributes present" do
        Fog.mock!
        @compute_resource.stubs(:key_pair).returns(mocked_key_pair)
        @compute_resource.expects(:process_fixed_ips).once

        @compute_resource.create_vm(
          :nics => [{ 'net_id' => 'network-123' }],
          :interfaces_attributes => { '0' => { 'ip' => '192.168.1.100' } },
          :flavor_ref => 'foo_flavor',
          :image_ref => 'foo_image'
        )
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

      def use_application_credentials(compute_resource)
        compute_resource.url = 'http://openstack.example.com/v3/auth/tokens'
        compute_resource.authentication_type = Openstack::APPLICATION_CREDENTIAL_AUTHENTICATION
        compute_resource.application_credential_id = 'credential-id'
        compute_resource.application_credential_secret = 'application-secret'
      end

      def mocked_key_pair
        key_pair = mock
        key_pair.stubs(:name).returns('foo_key')
        key_pair
      end
    end
  end
end
