require 'integration_test_helper'

class ReportTemplateIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    as_admin do
      FactoryBot.create(:report_template) # breadcrumbs are not present on welcome page
      assert_index_page(report_templates_path, "Report Templates", "Create Template")
    end
  end
end
