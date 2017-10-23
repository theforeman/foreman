require 'test_helper'

class OwnerClassifierTest < ActiveSupport::TestCase
  test "Should return user if id_and_type is a user" do
    usergrop = FactoryBot.create(:user)
    id_and_type = usergrop.id_and_type
    assert_equal usergrop, OwnerClassifier.new(id_and_type).user_or_usergroup
  end

  test "Should return usergroup if id_and_type is a usergroup" do
    usergrop = FactoryBot.create(:usergroup)
    id_and_type = usergrop.id_and_type
    assert_equal usergrop, OwnerClassifier.new(id_and_type).user_or_usergroup
  end

  test "Should return nil if id_and_type does not exist" do
    id_and_type = "0-Users"
    assert_nil OwnerClassifier.new(id_and_type).user_or_usergroup
  end

  test "Should return nil if id_and_type is ilegal" do
    id_and_type = "5-UsErS"
    assert_nil OwnerClassifier.new(id_and_type).user_or_usergroup
  end
end
