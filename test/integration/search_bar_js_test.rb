require 'integration_test_helper'

class SearchBarTest < IntegrationTestWithJavascript
  test "backslash key clicked should opens the search" do
    visit bookmarks_path
    work_around_selenium_file_detector_bug
    # needs to be interactive element
    find('table thead').find('a', text: 'Name').send_keys("/")
    assert_includes(page.evaluate_script("document.activeElement.classList"), "pf-v5-c-text-input-group__text-input")
  end
end
