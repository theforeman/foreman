require 'test_helper'

class StatisticTest < ActionDispatch::IntegrationTest

  test "statistics page" do
    visit statistics_path
    assert page.has_selector?('h4', :text => "OS Distribution")
    assert page.has_selector?('h4', :text => "Architecture Distribution")
    assert page.has_selector?('h4', :text => "Environments Distribution")
    assert page.has_selector?('h4', :text => "Number of CPUs")
    assert page.has_selector?('h4', :text => "Hardware")
    assert page.has_selector?('h4', :text => "Class Distribution")
    assert page.has_selector?('h4', :text => "Average memory usage")
    assert page.has_selector?('h4', :text => "Average swap usage")
  end

end
