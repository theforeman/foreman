require 'test_helper'

class ArchitectureTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(architectures_path, "s390")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(architectures_path, "x86_64")
  end

end
