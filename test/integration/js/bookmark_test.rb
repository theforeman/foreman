require 'test_helper'

class BookmarkTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(bookmarks_path, "foo", "Delete", false)
  end

end
