require 'integration_test_helper'

class AuditJSTest < IntegrationTestWithJavascript
  test "show audit with diff" do
    audit = FactoryGirl.create(:audit, :with_diff)
    visit audit_path(audit)
    assert has_content?('-old')
    assert has_content?('+new')
  end
end
