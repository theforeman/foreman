require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class Foreman::Model::RackspaceTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  should validate_presence_of(:url)

  test "#associated_host matches any NIC" do
    host = FactoryBot.create(:host, :ip => '10.0.0.154')
    cr = FactoryBot.build_stubbed(:rackspace_cr)
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

  describe '#normalize_vm_attrs' do
    let(:base_cr) { FactoryBot.build(:rackspace_cr) }
    let(:cr) do
      mock_cr(base_cr,
        :flavors => [
          stub(:id => 'flvr1', :name => 'flavour 1'),
          stub(:id => 'flvr2', :name => 'flavour 2')
        ]
      )
    end

    test 'finds flavor_name' do
      normalized = cr.normalize_vm_attrs('flavor_id' => 'flvr1')

      assert_equal('flavour 1', normalized['flavor_name'])
    end

    describe 'images' do
      let(:base_cr) { FactoryBot.create(:rackspace_cr, :with_images) }

      test 'adds image name' do
        vm_attrs = {
          'image_id' => cr.images.last.uuid
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(cr.images.last.name, normalized['image_name'])
      end

      test 'leaves image name empty when image_id is nil' do
        vm_attrs = {
          'image_id' => nil
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end

      test "leaves image name empty when image wasn't found" do
        vm_attrs = {
          'image_id' => 'unknown'
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end
    end

    test 'correctly fills empty attributes' do
      normalized = cr.normalize_vm_attrs({})
      expected_attrs = {
        'flavor_id' => nil,
        'flavor_name' => nil,
        'image_name' => nil,
        'image_id' => nil
      }

      assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end
end
