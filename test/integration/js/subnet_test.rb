require 'test_helper'

class SubnetTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(subnets_path, "three")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(subnets_path, "one")
  end

end
