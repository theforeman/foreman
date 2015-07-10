require 'test_helper'

class BookmarkIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(bookmarks_path,"Manage Bookmarks",false,false,true)
  end

  test "edit path" do
    visit bookmarks_path
    within("table") do
      click_link("foo")
    end
    fill_in "bookmark_name", :with => "recent"
    fill_in "bookmark_query", :with => "last_report > 60 minutes ago"
    assert_submit_button(bookmarks_path)
    assert page.has_link? "recent"
    assert page.has_content? 'last_report > 60 minutes ago'
  end
end
