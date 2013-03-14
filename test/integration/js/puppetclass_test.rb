require 'test_helper'

class PuppetclassTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(puppetclasses_path, "apache")
  end

  #PENDING - test is showing base can be deleted??
  test "cannot delete row if used" do
  #   assert_cannot_delete_row(puppetclasses_path, "base")
  end

end
