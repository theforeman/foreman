require 'integration_test_helper'

class RoleJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(roles_path, "Roles", "Create Role")
  end
end
