require 'test_helper'

class PtableTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(ptables_path, "four")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(ptables_path, "ubuntu default")
  end

end
