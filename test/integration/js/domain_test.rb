require 'test_helper'

class DomainTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(domains_path, "somewhare that is never used")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(domains_path, "mydomain.net")
  end

end
