require 'integration_test_helper'

class SearchBarTest < IntegrationTestWithJavascript
  test "backslash key clicked should opens the search" do
    visit bookmarks_path
    # needs to be interactive element
    find('table thead').find('a', text: 'Name').send_keys("/")
    assert_includes(page.evaluate_script("document.activeElement.classList"), "pf-c-text-input-group__text-input")
  end
end
