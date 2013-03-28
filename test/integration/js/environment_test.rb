require 'test_helper'

class EnvironmentTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(environments_path, "global_puppetmaster", "Delete", true)
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(environments_path, "production", "Delete", true)
  end

  #PENDING - Import from #{proxy.name}

end