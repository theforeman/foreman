require 'test_helper'

class VariableLookupKeyTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:key)
  should_not allow_value('with whitespace').for(:key)

  test "validates presence of puppetclass_id" do
    variable_lk = FactoryGirl.build(:variable_lookup_key)
    refute_valid variable_lk
    assert_equal "can't be blank", variable_lk.errors[:puppetclass_id].first
  end
end
