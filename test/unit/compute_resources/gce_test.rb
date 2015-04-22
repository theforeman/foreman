require 'test_helper'

class GCETest < ActiveSupport::TestCase
  context 'creation' do
    setup do
      Fog.mock!
      volumes_attributes = { :volumes => { :size_gb => '10'} }
      @args = { :name => 'foo_vm', :external_ip => 0, :image_name => 'foo_image',
                :volumes => volumes_attributes, :machine_type => 'f1.simple_foo',
                :image_id => 1 }

      @compute_resource = FactoryGirl.build(:gce_cr)
      @compute_resource.setup_key_pair
      @compute_resource.expects(:create_disk).with(@args[:volumes][:size_gb], @args[:image_id])
        .returns(@compute_resource.send(:client).disks.first)
    end

    test 'creating a vm triggers creation of an attached disk' do
      Fog::Compute::Google::Servers.any_instance.expects(:create)
      @compute_resource.create_vm(@args)
    end

    test 'failed creation of vm destroys newly created attached disks' do
      @compute_resource.stubs(:images).raises(Fog::Errors::Error)
      Fog::Compute::Google::Disk.any_instance.expects(:destroy)
      assert_raise Fog::Errors::Error do
        @compute_resource.create_vm(@args)
      end
    end
  end
end
