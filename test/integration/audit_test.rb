require 'integration_test_helper'

class AuditIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(audits_path, "Audits", nil, true)
  end
end
