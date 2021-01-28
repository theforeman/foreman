require 'integration_test_helper'

class AuthSourceJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(auth_sources_path, "Authentication Sources", nil, false, true)
  end
end
