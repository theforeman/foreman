require 'test_helper'

class VariableLookupKeyTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:key)
  should_not allow_value('with whitespace').for(:key)

  test "validates presence of puppetclass_id" do
    variable_lk = FactoryGirl.build(:variable_lookup_key)
    refute_valid variable_lk
    assert_equal "can't be blank", variable_lk.errors[:puppetclass_id].first
  end

  test "should have auditable_type as VariableLookupKey and not LookupKey" do
    VariableLookupKey.create(:key => 'test_audit_variable', :default_value => "test123", :puppetclass => puppetclasses(:one))
    assert_equal 'VariableLookupKey', Audit.unscoped.last.auditable_type
  end
end
