require 'test_helper'

class ComputeProfileTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)

  test "should not destroy if in use by hostgroup" do
    # hostgroups(:common) uses compute_profiles(:one)
    assert !compute_profiles(:one).destroy
  end

  test "can destroy if used by host, but not hostgroup, and ensure host.compute_profile_id is nullified" do
    compute_profile = compute_profiles(:two)
    host = FactoryBot.create(:host, :compute_profile => compute_profile)
    assert_difference('ComputeProfile.count', -1) do
      assert compute_profile.destroy
    end
    host.reload
    assert_nil host.compute_profile_id
  end

  test "shoud show visible hw profiles only" do
    assert_equal 4, ComputeProfile.count
    # 3-Large does not have any data in compute_attributes.yml
    assert_equal 3, ComputeProfile.visibles.count
  end

  test "compute profile with associated attributes can be destroyed" do
    assert_difference('ComputeAttribute.count', -2) do
      assert compute_attributes(:three).compute_profile.destroy
    end
  end

  test 'should update with multiple valid names' do
    compute_profile = FactoryBot.create(:compute_profile)
    valid_name_list.each do |name|
      compute_profile.name = name
      assert compute_profile.valid?, "Can't update compute profile with valid name #{name}"
    end
  end

  test 'should not update with multiple invalid names' do
    compute_profile = FactoryBot.create(:compute_profile)
    invalid_name_list.each do |name|
      compute_profile.name = name
      refute compute_profile.valid?, "Can update compute profile with invalid name #{name}"
      assert_includes compute_profile.errors.attribute_names, :name
    end
  end
end
