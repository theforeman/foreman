require 'test_helper'

class ReportTest < ActionDispatch::IntegrationTest
  def setup
    @report = FactoryGirl.create(:report, :old_report)
  end

  test "index page" do
    visit reports_path
    assert find_button('Search').visible?, "Search button is not visible"
  end

  test "reports for host" do
    visit reports_path
    click_link(@report.host.fqdn)
    assert_equal "host = #{@report.host.fqdn}", find_field('search').value
  end

  test "show specific report" do
    visit report_path(@report)
    assert page.has_selector?('h1', :text => @report.host.fqdn), "hostname was expected in the <h1> tag, but was not found"
  end

  test "delete a report redirects to reports index" do
    visit report_path(@report)
    first(:link, "Delete").click
    assert_equal(current_path, reports_path)
  end
end
