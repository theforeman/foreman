require 'integration_test_helper'

class ModelJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(models_path, "Hardware Models", "Create Model")
  end
end
