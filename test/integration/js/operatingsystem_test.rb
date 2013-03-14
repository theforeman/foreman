require 'test_helper'

class OperatingsystemTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(operatingsystems_path, "NoHosts")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(operatingsystems_path, "centos")
  end

end
