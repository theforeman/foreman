require 'test_helper'

class ComputeAttributeTest < ActiveSupport::TestCase
  setup do
    Fog.mock!
    User.current = users :admin
    @set = compute_attributes(:one)
    @compute_profile = @set.compute_profile  #1-Small
    @compute_resource = @set.compute_resource  #EC2
  end

  teardown do
    Fog.unmock!
  end

  test "save if unique" do
    set = ComputeAttribute.new :compute_resource_id => @compute_resource.id, :compute_profile_id => compute_profiles(:three).id
    assert set.save
  end

  test "do not save if not unique" do
    set = ComputeAttribute.new :compute_resource_id => @compute_resource.id, :compute_profile_id => @compute_profile.id
    assert !set.save
  end

  test "getter attributes in vm_attrs hash" do
    assert_equal 'm1.small', @set.flavor_id
    assert_equal 'eu-west-1a', @set.availability_zone
  end

  test "raise error for nonexistant getter attribute in vm_attrs hash" do
    assert_raise Foreman::Exception do
      @set.nonexistant_flavor_field
    end
  end

  describe "vm_interfaces" do
    test "returns array of interface attributes" do
      set = compute_attributes(:with_interfaces)
      expected_vm_interfaces = [
        {'attr' => 1},
        {'attr' => 2}
      ]
      assert_equal expected_vm_interfaces, set.vm_interfaces
    end

    test "returns empty array if interface attributes are missing" do
      set = compute_attributes(:one)
      assert_empty set.vm_interfaces
    end
  end
end
