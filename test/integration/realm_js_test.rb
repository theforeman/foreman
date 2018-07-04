require 'integration_test_helper'

class RealmJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(realms_path, "Realms", "Create Realm")
  end
end
