require 'test_helper'

class ComputeProfileTest < ActiveSupport::TestCase
  setup do
    User.current = User.admin
  end

  test "name can't be blank" do
    cp = ComputeProfile.new :name => "   "
    assert !cp.save
  end

  test "name must be unique" do
    cp = ComputeProfile.new :name => "1-Small"
    assert !cp.save
  end

  test "should not destroy if in use by hostgroup" do
    #hostgroups(:common) uses compute_profiles(:one)
    assert !compute_profiles(:one).destroy
  end

  test "shoud show visible hw profiles only" do
    assert_equal 3, ComputeProfile.count
    #3-Large does not have any data in compute_attributes.yml
    assert_equal 2, ComputeProfile.visibles.count
  end

  test "compute profile with associated attributes can be destroyed" do
    assert_difference('ComputeAttribute.count', -2) do
      assert compute_attributes(:three).compute_profile.destroy
    end
  end
end
