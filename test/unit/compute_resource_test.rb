require 'test_helper'

class ComputeResourceTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  test "password is saved encrypted when updated" do
    compute_resource = compute_resources(:one)
    compute_resource.password = "123456"
    as_admin do
      assert compute_resource.save
    end
    assert_equal compute_resource.password, "123456"
    refute_equal compute_resource.password_in_db, "123456"
  end

  test "password is saved encrypted when created" do
    Fog.mock!
    compute_resource = ComputeResource.new_provider(:name => "new12345", :provider => "EC2", :url => "eu-west-1",
                                                    :user => "username", :password => "abcdef")
    as_admin do
      assert compute_resource.save!
    end
    assert_equal compute_resource.password, "abcdef"
    refute_equal compute_resource.password_in_db, "abcdef"
  end

  test "random_password should return nil when set_console_password is false" do
    cr=compute_resources(:mycompute)
    cr.set_console_password=0
    assert_nil cr.send(:random_password) # Can't call protected methods directly
  end

  test "random_password should return a string when set_console_password is true" do
    cr=compute_resources(:mycompute)
    cr.set_console_password=1
    assert_match /^[[:alnum:]]+$/, cr.send(:random_password) # Can't call protected methods directly
  end

  test "libvirt vm_instance_defaults should contain the stored display type" do
    cr=compute_resources(:mycompute)
    cr.display_type='VNC'
    assert_equal 'vnc', cr.send(:vm_instance_defaults)['display']['type']
    cr.display_type='SPICE'
    assert_equal 'spice', cr.send(:vm_instance_defaults)['display']['type']
  end

  test "libvirt: 'G' suffix should be appended to libvirt volume capacity if none was specified" do
    volume = OpenStruct.new(:capacity => 10)
    volume.stubs(:save!).returns(true)

    result = Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]})

    assert_equal "10G", result[0].capacity
  end

  test "libvirt: no exceptions should be raised if a 'G' suffix was specified for volume capacity" do
    volume = OpenStruct.new(:capacity => "10G")
    volume.stubs(:save!).returns(true)

    assert_nothing_raised { Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]}) }
  end

  test "libvirt: an exception should be raised if a suffix other than 'G' was used in volume capacity value" do
    volume = OpenStruct.new(:capacity => "10K")

    assert_raise(Foreman::Exception) do
      Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]})
    end
  end
end
