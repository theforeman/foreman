require 'integration_test_helper'

class AuditJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(audits_path, "Audits", nil, true)
  end
  describe "Context API" do
    setup do
      @entries = Setting[:entries_per_page]
    end

    teardown do
      Setting[:entries_per_page] = @entries
    end
    test "Check per page settings in context" do
      Setting['entries_per_page'] = 8
      visit audits_path
      per_page = page.find('#pagination-row-dropdown').text
      assert_equal per_page, '8'
    end
  end
end
