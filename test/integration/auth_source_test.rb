require 'integration_test_helper'

class AuthSourcesIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(auth_sources_path, "Authentication sources", nil, false, true)
  end
end
