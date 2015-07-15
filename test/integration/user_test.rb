require 'test_helper'

class UserIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(users_path,"Users","New User")
  end

  test "edit page" do
    visit users_path
    click_link "one"
    fill_in "user_login", :with => "user12345"
    assert_submit_button(users_path)
    assert page.has_link? 'user12345'
  end
end
