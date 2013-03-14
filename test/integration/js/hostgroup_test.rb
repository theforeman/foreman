require 'test_helper'

class HostgroupTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(hostgroups_path, "Unusual", "Delete", true)
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(hostgroups_path, "Common", "Delete", true)
  end

  #PENDING - nest

  #PENDING - clone

end
