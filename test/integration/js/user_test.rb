require 'test_helper'

class UserTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "create new page" do
    assert_new_button(users_path,"New User",new_user_path)
    fill_in "user_login", :with => "user10"
    fill_in "user_firstname", :with => "John"
    fill_in "user_lastname", :with => "Doe"
    fill_in "user_mail", :with => "user10@example.com"
    select "INTERNAL", :from => "user_auth_source_id"
    fill_in "user_password", :with => "secret"
    fill_in "user_password_confirmation", :with => "secret"
    assert_submit_button(users_path)
    assert page.has_link? "user10"
  end

  test "sucessfully delete row" do
    assert_delete_row(users_path, "two")
  end

  test "cannot delete row if used" do
    # context - assign user to host
    h = hosts(:one)
    h.owner_id, h.owner_type = users(:one).id, "User"
    User.current = User.admin  #error - undefine allowed_to? if User.current not defined
    h.save(:validate => false)
    assert_cannot_delete_row(users_path, "one")
  end


end
