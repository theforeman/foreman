require 'test_helper'

class UserTest < ActionDispatch::IntegrationTest
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

  context 'javascript test' do
    def setup
      Capybara.current_driver = Capybara.javascript_driver
    end

    test "notice is removed after submit pressed" do
      visit "/"
      fill_in "login_login", :with => users(:admin).login
      fill_in "login_password", :with => "badPass"
      click_button "Login"
      assert page.has_selector?('div.jnotify-message'), "notice wasn't on page after login with bad credentials"
      execute_script("$('#login-form').submit(function(e){return false;});")
      fill_in "login_login", :with => users(:admin).login
      fill_in "login_password", :with => "secret"
      click_button "Login"
      assert_not page.has_selector?('div.jnotify-message'), "notice wasn't removed after login was clicked"
    end
  end
end
