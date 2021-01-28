require 'integration_test_helper'

class BookmarkJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(bookmarks_path, "Bookmarks", false, false, true)
  end

  test "edit path" do
    visit bookmarks_path
    within("table") do
      click_link("foo")
    end
    assert page.has_content? 'foo=boo'
    fill_in "bookmark_name", :with => "recent"
    fill_in "bookmark_query", :with => "last_report > 60 minutes ago"
    assert_submit_button(bookmarks_path)
    assert page.has_link? "recent"
    assert page.has_content? 'last_report > 60 minutes ago'
  end
end
