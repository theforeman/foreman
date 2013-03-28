require 'test_helper'

class LookupKeyTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(lookup_keys_path, "cluster")
  end

end
