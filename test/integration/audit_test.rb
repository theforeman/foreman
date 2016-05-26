require 'integration_test_helper'

class AuditIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(audits_path,"Audits",nil,true)
  end

  test "audit content" do
    visit audits_path
    assert has_content?("updated Host"), "expected 'updated Host' but it doesn't exist"
  end

  test "show audit with diff" do
    Capybara.current_driver = Capybara.javascript_driver
    login_admin
    audit = FactoryGirl.create(:audit, :with_diff)
    visit audit_path(audit)
    assert has_content?('-old')
    assert has_content?('+new')
  end
end
