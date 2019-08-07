require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class Foreman::Model::LibvirtTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  should validate_presence_of(:url)
  should allow_values(*valid_name_list).for(:name)
  should allow_values(*valid_name_list).for(:description)
  should_not allow_values(*invalid_name_list).for(:name)

  test "#associated_host matches any NIC" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:97')
    Nic::Base.create! :mac => "ca:d0:e6:32:16:99", :host => host
    host.reload
    cr = FactoryBot.build_stubbed(:libvirt_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test "#associated_host matches any NIC with upper case MAC" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:97')
    Nic::Base.create! :mac => "ca:d0:e6:32:16:99", :host => host
    host.reload
    cr = FactoryBot.build_stubbed(:libvirt_cr)
    iface = mock('iface1', :mac => 'CA:D0:E6:32:16:97')
    vm = mock('vm', :interfaces => [iface])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test 'should update with multiple valid names' do
    compute_resource = FactoryBot.create(:libvirt_cr)
    valid_name_list.each do |name|
      compute_resource.name = name
      assert compute_resource.valid?, "Can't update compute resource with valid name #{name}"
    end
  end

  test 'should not update with multiple invalid names' do
    compute_resource = FactoryBot.create(:libvirt_cr)
    invalid_name_list.each do |name|
      compute_resource.name = name
      refute compute_resource.valid?, "Can update compute resource with invalid name #{name}"
      assert_includes compute_resource.errors.keys, :name
    end
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

      cr = FactoryBot.build_stubbed(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_equal 6 * 1024, attrs[:memory]
    end

    test "returns nil memory when :memory_size is not provided" do
      vm = mock()
      vm.stubs(:attributes).returns({})

      cr = FactoryBot.build_stubbed(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_nil attrs[:memory]
    end
  end

  describe '#display_type' do
    let(:cr) { FactoryBot.build_stubbed(:libvirt_cr) }

    test "default display type is 'vnc'" do
      assert_nil cr.attrs[:display]
      assert_equal 'vnc', cr.display_type
    end

    test "display type can be set" do
      expected = 'spice'
      cr.display_type = 'SPICE'
      assert_equal expected, cr.attrs[:display]
      assert_equal expected, cr.display_type
      assert cr.valid?
    end

    test "don't allow wrong display type to be set" do
      cr.display_type = 'teletype'
      refute cr.valid?
    end
  end

  describe '#create_vm' do
    let(:cr) { FactoryBot.build_stubbed(:libvirt_cr) }

    test 'exceptions are not obscured' do
      vm = mock('vm')
      cr.expects(:new_vm).returns(vm)
      cr.expects(:create_volumes).raises(Fog::Errors::Error.new('create_error'))
      cr.expects(:destroy_vm).raises(Fog::Errors::Error.new('destroy_error'))
      vm.stubs(:id).returns(1)
      vm.stubs(:name).returns(nil)
      vm.stubs(:volumes).returns(nil)

      err = assert_raises Fog::Errors::Error do
        cr.create_vm
      end

      assert_equal 'create_error', err.message
    end
  end

  describe '#new_volume' do
    let(:cr) { FactoryBot.build_stubbed(:libvirt_cr) }

    test 'new_volume_errors reports error for empty storage pool' do
      cr.stubs(:storage_pools).returns([]) do
        assert_equal 1, cr.new_volume_errors.size
      end
    end

    test 'new_volume returns nil if there is an error' do
      cr.stubs(:new_volume_errors).returns(['something']) do
        assert_nil cr.new_volume({})
      end
    end
  end

  describe '#normalize_vm_attrs' do
    let(:cr) { FactoryBot.build(:libvirt_cr) }

    describe 'images' do
      let(:cr) { FactoryBot.create(:libvirt_cr, :with_images) }

      test 'adds image name' do
        vm_attrs = {
          'image_id' => cr.images.last.uuid,
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(cr.images.last.name, normalized['image_name'])
      end

      test 'leaves image name empty when image_id is nil' do
        vm_attrs = {
          'image_id' => nil,
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end

      test "leaves image name empty when image wasn't found" do
        vm_attrs = {
          'image_id' => 'unknown',
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end
    end

    describe 'volumes_attributes' do
      test 'adds volumes_attributes when they were missing' do
        normalized = cr.normalize_vm_attrs({})

        assert_equal({}, normalized['volumes_attributes'])
      end

      test 'normalizes volumes_attributes' do
        vm_attrs = {
          'volumes_attributes' => {
            '1' => {
              'capacity' => '1GB',
              'allocation' => '2GB',
              'pool_name' => 'pool1',
              'format_type' => 'qcow',
              'unknown' => 'value',
            },
          },
        }
        expected_attrs = {
          '1' => {
            'capacity' => 1.gigabyte.to_s,
            'allocation' => 2.gigabyte.to_s,
            'pool' => 'pool1',
            'format_type' => 'qcow',
          },
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(expected_attrs, normalized['volumes_attributes'])
      end
    end

    describe 'interfaces_attributes' do
      test 'adds interfaces_attributes when they were missing' do
        normalized = cr.normalize_vm_attrs({})

        assert_equal({}, normalized['interfaces_attributes'])
      end

      test 'normalizes interfaces_attributes' do
        vm_attrs = {
          'nics_attributes' => {
            '1' => {
              'type' => 'network',
              'network' => 'default',
              'bridge' => nil,
              'model' => 'virtio',
              'unknown' => 'value',
            },
            '2' => {
              'type' => 'bridge',
              'network' => nil,
              'bridge' => 'br1',
              'model' => 'virtio',
            },
          },
        }
        expected_attrs = {
          '1' => {
            'type' => 'network',
            'network' => 'default',
            'model' => 'virtio',
          },
          '2' => {
            'type' => 'bridge',
            'bridge' => 'br1',
            'model' => 'virtio',
          },
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(expected_attrs, normalized['interfaces_attributes'])
      end
    end

    test 'correctly fills empty attributes' do
      normalized = cr.normalize_vm_attrs({})
      expected_attrs = {
        "cpus" => nil,
        "memory" => nil,
        "volumes_attributes" => {},
        "image_id" => nil,
        "image_name" => nil,
        "interfaces_attributes" => {},
      }

      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end
end
