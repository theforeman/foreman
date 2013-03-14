require 'test_helper'

class TopBarTest < ActionDispatch::IntegrationTest

  test "top bar links" do
    visit root_path
    within("div.navbar-inner") do
      assert page.has_link?("Foreman", :href => "/")
      assert page.has_link?("Dashboard", :href => "/dashboard")
      assert page.has_link?("Hosts", :href => "/hosts")
      assert page.has_link?("Reports", :href => "/reports?search=eventful+%3D+true")
      assert page.has_link?("Facts", :href => "/fact_values")
      assert page.has_link?("Audits", :href => "/audits")
      assert page.has_link?("Statistics", :href => "/statistics")
      assert page.has_link?("Trends", :href => "/trends")
    end
  end

  test "Foreman link" do
    visit root_path
    within("div.navbar-inner") do
      click_link("Foreman")
    end
    assert page.has_selector?('h1', :text => "Overview")
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
      click_link("Hosts")
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
