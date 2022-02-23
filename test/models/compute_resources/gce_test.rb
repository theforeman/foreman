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
            '0' => {
              'size_gb' => '1GB',
              'id' => '',
            },
          },
        }
        expected_attrs = {
          '0' => {
            'size' => 1.gigabyte.to_s,
          },
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
        'associate_external_ip' => nil,
        'image_id' => nil,
        'image_name' => nil,
        'volumes_attributes' => {},
      }

      assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end

  describe '#associated_host' do
    let(:cr) { FactoryBot.build_stubbed(:gce_cr) }

    test "matches host by public_ip_address NIC" do
      host = FactoryBot.create(:host, :ip => '10.0.0.154')
      compute = mock('gce_compute', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
      assert_equal host, as_admin { cr.associated_host(compute) }
    end

    test "matches host by private_ip_address NIC" do
      host = FactoryBot.create(:host, :ip => '10.1.1.1')
      compute = mock('gce_compute', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
      assert_equal host, as_admin { cr.associated_host(compute) }
    end
  end

  describe '#check_google_key_format_and_options' do
    let(:cr) { FactoryBot.build_stubbed(:gce_cr) }

    test 'passes when valid Google JSON key includes client_email, private_key' do
      valid_key = {
        'type' => 'service_account',
        'project_id' => 'dummy-project',
        'private_key' => '-----BEGIN PRIVATE KEY-----\n..\n-----END PRIVATE KEY-----\n ',
        'client_email' => 'dummy@dummy-project.iam.gserviceaccount.com',
      }
      cr.stubs(:read_key_file).returns(valid_key)
      result = cr.send(:check_google_key_format_and_options)

      assert_nil(result)
      assert cr.valid?, "Can't create GCE compute resource with valid JSON #{valid_key}"
    end

    test 'fails when required keys are missing in Google JSON key' do
      cr.stubs(:read_key_file).returns({ 'project_id' => 'dummy-project' })
      cr.send(:check_google_key_format_and_options)

      assert_not cr.valid?
      assert_include cr.errors.attribute_names, :key_path
    end

    test 'fails when Google key is not a valid JSON' do
      raises_exception = -> { raise JSON::ParserError.new }
      cr.stub(:read_key_file, raises_exception) do
        cr.send(:check_google_key_format_and_options)

        assert_not cr.valid?
        assert_include cr.errors.attribute_names, :key_path
        assert_include cr.errors[:key_path], 'Certificate key is not a valid JSON'
      end
    end
  end

  test 'fails when provided zone is not a valid on GCE' do
    cr = FactoryBot.build(:gce_cr, :zone => 'xyz')
    cr.send(:validate_zone)

    assert_not cr.valid?
    assert_include cr.errors.attribute_names, :zone
    assert_include cr.errors[:zone], 'is not valid'
  end

  describe '#available_images' do
    let(:cr) { FactoryBot.create(:gce_cr, :with_images) }

    test "should display only current images from GCE" do
      image1 = mock('image1')
      image2 = mock('image2')
      image3 = mock('image3')

      mock_images = [image1, image2, image3]
      mock_images.stubs('current').returns([image1, image3])
      mock_client = mock('client')
      mock_client.stubs(:images).returns(mock_images)
      cr.stubs(:client).returns(mock_client)
      cr.stubs(:image_families_to_filter).returns([])

      gce_images = cr.send(:client).images
      current_images = cr.available_images.dup
      assert_not_equal(gce_images.count, current_images.count)
    end

    test "should filter images when register with any image families" do
      image1 = mock('image1')
      image2 = mock('image2')
      image3 = mock('image3')

      mock_images = [image1, image2, image3]
      mock_images.stubs('current').returns([image1, image3])
      mock_client = mock('client')
      mock_client.stubs(:images).returns(mock_images)
      cr.stubs(:client).returns(mock_client)
      cr.stubs(:image_families_to_filter).returns(['rhel'])

      image1.expects(:family).returns('rhel-6')
      image3.expects(:family).returns('centos-6')

      filtered_current_images = cr.available_images
      assert_includes filtered_current_images, image1
      assert_equal 1, filtered_current_images.count
    end
  end
end
