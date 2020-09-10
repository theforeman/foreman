require 'test_helper'

class ScopedSearchExtensionsTest < ActiveSupport::TestCase
  def setup
    @search_class = Class.new { include ScopedSearchExtensions }
  end

  test "should change * to %" do
    input = "test*"
    assert_equal "test%", @search_class.value_to_sql("like", input)
  end
end
