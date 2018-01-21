require 'integration_test_helper'

class VariableLookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(variable_lookup_keys_path,"Smart Variables",false)
  end
end
