require 'integration_test_helper'

class CommonParameterJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(common_parameters_path, "Global Parameters", "Create Parameter")
  end
end
