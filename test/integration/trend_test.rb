require 'test_helper'

class TrendIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    visit trends_path
    assert page.has_selector?('h1', :text => "Trends"), "Trends was expected in the <h1> tag, but was not found"
    assert find_link("Add Trend Counter").visible?, "Add Trend Counter is not visible"
  end

  #PENDING
  # test "create new page" do
  #   assert_new_button(trends_path,"Add Trend Counter",new_trend_path)
  #   fill_in "trend_name", :with => "architecture"
  #   assert_submit_button(trends_path)
  #   assert page.has_link? "architecture"
  # end

  #PENDING - SHOW trend
end
