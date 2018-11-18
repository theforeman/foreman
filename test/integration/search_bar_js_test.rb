require 'integration_test_helper'

class SearchBarTest < IntegrationTestWithJavascript
  test "backslash key clicked should opens the search" do
    visit bookmarks_path
    find('table').send_keys "/"
    assert find('.search-input.focus')
  end
end
