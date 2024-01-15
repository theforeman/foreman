require 'test_helper'

class OwnerClassifierTest < ActiveSupport::TestCase
  test "Should return user if id_and_type is a user" do
    user = FactoryBot.create(:user)
    id_and_type = user.id_and_type
    assert_equal user, OwnerClassifier.classify_owner(id_and_type)
  end

  test "Should return usergroup if id_and_type is a usergroup" do
    usergroup = FactoryBot.create(:usergroup)
    id_and_type = usergroup.id_and_type
    assert_equal usergroup, OwnerClassifier.classify_owner(id_and_type)
  end

  test "Should raise exception if id_and_type does not exist" do
    id_and_type = "0-Users"
    assert_raises(ActiveRecord::RecordNotFound) { OwnerClassifier.classify_owner(id_and_type) }
  end

  test "Should raise exception if id_and_type format is invalid" do
    id_and_type = "5-UsErS"
    assert_raises(ArgumentError) { OwnerClassifier.classify_owner(id_and_type) }
  end

  test "Deprecated method: user_or_usergroup should return user if id_and_type is a user" do
    user = FactoryBot.create(:user)
    id_and_type = user.id_and_type

    assert_deprecated do
      owner = OwnerClassifier.new(id_and_type).user_or_usergroup
      assert_equal user, owner
    end
  end
end
