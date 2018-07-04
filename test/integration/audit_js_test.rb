require 'integration_test_helper'

class AuditJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(audits_path, "Audits", nil, true)
  end
end
