require 'test_helper'

class ModelTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(models_path, "KVM")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(models_path, "SUN V210")
  end

end
