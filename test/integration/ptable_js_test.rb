require 'integration_test_helper'

class PtableJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(ptables_path, "Partition Tables", "Create Partition Table")
  end
end
