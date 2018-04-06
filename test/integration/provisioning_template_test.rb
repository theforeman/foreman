require 'integration_test_helper'

class ProvisioningTemplateIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(provisioning_templates_path, "Provisioning Templates", "Create Template")
  end
end
