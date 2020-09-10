require 'integration_test_helper'

class OperatingsystemJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(operatingsystems_path, "Operating Systems", "Create Operating System")
  end
end
