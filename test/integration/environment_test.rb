require 'test_helper'

class EnvironmentTest < ActionDispatch::IntegrationTest

  test "get environments" do
    visit "/environments"
    page.has_selector?('h1', :text => 'Environments')
    assert find_link('New Environment').visible?
    assert find_button('Search').visible?
  end

  test "create new environment" do
    visit "/environments"
    click_link "New Environment"
    assert_equal current_path, new_environment_path
    fill_in "environment_name", :with => "golive"
    click_button "Submit"
    assert_equal current_path, environments_path
    assert page.has_content? 'golive'
  end

  test "edit environment" do
    visit "/environments"
    click_link "production"
    fill_in "environment_name", :with => "production222"
    click_button "Submit"
    assert_equal current_path, environments_path
    assert page.has_content? 'production222'
  end

  # PENDING
  # test "delete environment" do
  #   #Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  #   visit "/environments"
  #   find(:xpath, "//table/tr[contains(.,'global_puppetmaster')]/td/a", :text => 'Delete').click
  #   click_link "OK"
  #   assert_equal current_path, environments_path
  #   assert !(page.has_content? "global_puppetmaster")
  # end

end