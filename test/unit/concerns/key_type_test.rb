require 'test_helper'

class KeyTypeTest < ActiveSupport::TestCase
  test "format_value_before_type_cast does not double encode json string" do
    val = '["server","admin-access"]'
    result = Parameter.format_value_before_type_cast(val, "json")
    assert_equal val, result
  end

  test "format_value_before_type_cast correctly serializes ruby array to json" do
    val = ["server", "admin-access"]
    result = Parameter.format_value_before_type_cast(val, "json")
    assert_equal JSON.dump(val), result
  end

  test "format_value_before_type_cast does not double encode yaml string" do
    val = "key: value"
    result = Parameter.format_value_before_type_cast(val, "yaml")
    assert_equal val, result
  end
end
