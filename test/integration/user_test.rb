require 'integration_test_helper'

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

  context "without automatic login" do
    def login_admin; end

    test "login" do
      visit "/"
      fill_in "login_login", :with => users(:admin).login
      fill_in "login_password", :with => "secret"
      click_button "Login"
      assert_current_path root_path
    end
  end
end
