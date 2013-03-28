require 'test_helper'

class UsergroupTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(usergroups_path, "Engineers")
  end

  test "cannot delete row if used" do
    # context - assign usergroup to host
    h = hosts(:one)
    h.owner_id, h.owner_type = usergroups(:one).id, "Usergroup"
    User.current = User.admin  #error - undefine allowed_to? if User.current not defined
    h.save(:validate => false)
    assert_cannot_delete_row(usergroups_path, "Admins")
  end

end
