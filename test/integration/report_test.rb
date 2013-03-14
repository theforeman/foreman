require 'test_helper'

class ReportTest < ActionDispatch::IntegrationTest

  test "index page" do
    visit reports_path
    assert find_button('Search').visible?, "Search button is not visible"
  end

  test "reports for host" do
    visit reports_path
    click_link("my5name.mydomain.net")
    assert_equal 'host = my5name.mydomain.net', find_field('search').value
  end

  test "show specific report" do
    visit reports_path
    click_link("7 days ago")
    assert page.has_selector?('h1', :text => "my5name.mydomain.net"), "'my5name.mydomain.net' was expected in the <h1> tag, but was not found"
  end

end
