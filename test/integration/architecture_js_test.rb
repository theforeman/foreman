require 'integration_test_helper'

class ArchitectureJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(architectures_path, "Architectures", "Create Architecture")
  end
end
