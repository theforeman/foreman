require 'integration_test_helper'

class AuditJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  # AuditJSTest.test_0001_show audit with diff

  test "show audit with diff" do
    audit = FactoryBot.create(:audit, :with_diff)
    visit audit_path(audit)
    assert has_content?('-old')
    assert has_content?('+new')
  end
end
