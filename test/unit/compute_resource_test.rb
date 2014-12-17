require 'test_helper'

module Best; module Provider; class MyBest < ::ComputeResource; end; end; end

class ComputeResourceTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  test "password is saved encrypted when updated" do
    compute_resource = compute_resources(:one)
    compute_resource.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    compute_resource.password = "123456"
    as_admin do
      assert compute_resource.save
    end
    assert_equal compute_resource.password, "123456"
    refute_equal compute_resource.password_in_db, "123456"
  end

  test "password is saved encrypted when created" do
    Fog.mock!
    ComputeResource.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    compute_resource = ComputeResource.new_provider(:name => "new12345", :provider => "EC2", :url => "eu-west-1",
                                                    :user => "username", :password => "abcdef")
    as_admin do
      assert compute_resource.save!
    end
    assert_equal compute_resource.password, "abcdef"
    refute_equal compute_resource.password_in_db, "abcdef"
    Fog.unmock!
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

  test "attrs[:setpw] is set to nil if compute resource is not Libvirt or VMWare" do
    cr = compute_resources(:ec2)
    assert cr.update_attributes(:set_console_password => 1)
    assert_nil cr.attrs[:setpw]
  end

  test "attrs[:setpw] is set to 1 if compute resource is Libvirt" do
    cr = compute_resources(:mycompute)
    assert cr.update_attributes(:set_console_password => 1)
    assert_equal 1, cr.attrs[:setpw]
  end

  test "attrs[:setpw] is set to 0 rather than nil if compute resource is Libvirt" do
    cr = compute_resources(:mycompute)
    assert cr.update_attributes(:set_console_password => nil)
    assert_equal 0, cr.attrs[:setpw]
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

  test "friendly provider name" do
    assert_equal "Libvirt", compute_resources(:one).provider_friendly_name
    assert_equal "EC2", compute_resources(:ec2).provider_friendly_name
    assert_equal "OpenStack", compute_resources(:openstack).provider_friendly_name
  end

  test "ensure compute resource with associated profile can get destroyed" do
    assert_difference('ComputeAttribute.count', -2) do
      compute_attributes(:one).compute_resource.destroy
    end
  end

  test "add compute resource" do
    ComputeResource.register_provider(Best::Provider::MyBest)
    assert ComputeResource.supported_providers.keys.must_include('MyBest')
    assert ComputeResource.supported_providers.values.must_include('Best::Provider::MyBest')
    refute ComputeResource.providers.wont_include('MyBest')
    SETTINGS[:mybest] = true
    assert ComputeResource.providers.must_include('MyBest')
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryGirl.create(:host, :compute_resource => compute_resources(:one),
                       :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], compute_resources(:one).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], compute_resources(:one).used_or_selected_location_ids
  end

  test "user_data_supported?" do
    refute compute_resources(:one).user_data_supported?
    assert compute_resources(:ec2).user_data_supported?
  end

  test "invalid if provider is set to empty string" do
    cr = compute_resources(:mycompute)
    cr.provider = ''
    refute_valid cr, :provider, "can't be blank"
    refute_valid cr, :provider, "is not included in the list"
  end

  test "invalid if provider is set to non-existant provider" do
    cr = compute_resources(:mycompute)
    cr.provider = 'notrealprovider'
    refute_valid cr, :provider, "is not included in the list"
  end

  test "invalid if provider is changed on update" do
    cr = compute_resources(:ovirt)
    cr.provider = 'Libvirt'
    refute_valid cr, :provider, "cannot be changed"
  end

  test "description supports more than 255 characters" do
    unless ActiveRecord::Base.connection.instance_values["config"][:adapter] == 'sqlite3'
      # rails uses text(255) with sqlite
      description = "a" * 300
      assert (description.length > 255)
      cr = compute_resources(:mycompute)
      cr.description = description
      assert_valid cr
    end
  end

  test "#associate_by returns host by MAC attribute" do
    host = FactoryGirl.create(:host, :mac => '11:22:33:44:55:1a')
    cr = FactoryGirl.build(:compute_resource)
    assert_equal host, as_admin { cr.send(:associate_by, 'mac', '11:22:33:44:55:1a') }
  end

  test "#associated_by returns read/write host" do
    FactoryGirl.create(:host, :mac => '11:22:33:44:55:1a')
    cr = FactoryGirl.build(:compute_resource)
    refute as_admin { cr.send(:associate_by, 'mac', '11:22:33:44:55:1a') }.readonly?
  end
end
