require 'test_helper'

class CommonParameterTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(common_parameters_path, "test")
  end

end
