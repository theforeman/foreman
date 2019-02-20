require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class Foreman::Model::GCETest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  describe '#normalize_vm_attrs' do
    let(:cr) { FactoryBot.build(:gce_cr) }

    describe 'associate_external_ip' do
      test 'normalizes 1 to true' do
        normalized = cr.normalize_vm_attrs({ 'associate_external_ip' => '1' })

        assert_equal(true, normalized['associate_external_ip'])
      end

      test 'normalizes 0 to false' do
        normalized = cr.normalize_vm_attrs({ 'associate_external_ip' => '0' })

        assert_equal(false, normalized['associate_external_ip'])
      end
    end

    describe 'images' do
      let(:cr) { FactoryBot.create(:gce_cr, :with_images) }

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

    describe 'volumes_attributes' do
      test 'adds volumes_attributes when they were missing' do
        normalized = cr.normalize_vm_attrs({})

        assert_equal({}, normalized['volumes_attributes'])
      end

      test 'normalizes volumes_attributes' do
        vm_attrs = {
          'volumes_attributes' => {
            '0' => {
              'size_gb' => '1GB',
              'id' => ''
            }
          }
        }
        expected_attrs = {
          '0' => {
            'size' => 1.gigabyte.to_s
          }
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(expected_attrs, normalized['volumes_attributes'])
      end
    end

    test 'correctly fills empty attributes' do
      normalized = cr.normalize_vm_attrs({})
      expected_attrs = {
        'machine_type' => nil,
        'network' => nil,
        'external_ip' => nil,
        'image_id' => nil,
        'image_name' => nil,
        'volumes_attributes' => {}
      }

      assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end
end
