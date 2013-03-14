require 'test_helper'

class MediaTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(media_path, "unused")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(media_path, "CentOS 5.4")
  end

end
