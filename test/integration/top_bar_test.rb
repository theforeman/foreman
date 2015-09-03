require 'test_helper'

class TopBarIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => FactoryGirl.create(:host),
                       :fact_name => FactoryGirl.create(:fact_name) )
  end

  test "top bar links" do
    visit root_path
    within("div.navbar-outer") do
      assert page.has_link?("Foreman", :href => "/")
    end
    within("div.navbar-inner") do
      assert page.has_link?("Dashboard", :href => "/dashboard")
      assert page.has_link?("All hosts", :href => "/hosts")
      assert page.has_link?("Config management", :href => "/config_reports?search=eventful+%3D+true")
      assert page.has_link?("Facts", :href => "/fact_values")
      assert page.has_link?("Audits", :href => "/audits")
      assert page.has_link?("Statistics", :href => "/statistics")
      assert page.has_link?("Trends", :href => "/trends")
    end
  end

  test "Dashboard link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Dashboard")
    end
    assert page.has_selector?('h1', :text => "Overview")
  end

  test "Hosts link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("All hosts")
    end
    assert page.has_selector?('h1', :text => "Hosts")
  end

  test "Facts link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Facts")
    end
    assert page.has_selector?('h1', :text => "Fact Values")
  end

  test "Audits link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Audits")
    end
    assert page.has_selector?('h1', :text => "Audits")
  end

  test "Statistics link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Statistics")
    end
    assert page.has_selector?('h4', :text => "OS Distribution")
  end

  test "Trends link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Trends")
    end
    assert page.has_selector?('h1', :text => "Trends")
  end

  #PENDING - click on Menu Bar js
end
