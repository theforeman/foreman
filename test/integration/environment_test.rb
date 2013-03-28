require 'test_helper'

class EnvironmentTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(environments_path,"Environments","New Environment")
  end

  test "create new page" do
    assert_new_button(environments_path,"New Environment",new_environment_path)
    fill_in "environment_name", :with => "golive"
    assert_submit_button(environments_path)
    assert page.has_link? 'golive'
  end

  test "edit page" do
    visit environments_path
    click_link "production"
    fill_in "environment_name", :with => "production222"
    assert_submit_button(environments_path)
    assert page.has_link? 'production222'
  end

end