require 'test_helper'

class SystemTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(systems_path,"Systems","New System")
  end

  test "create new page" do
    assert_new_button(systems_path,"New System",new_system_path)
    assert page.has_link?("System", :href => "#primary")
    assert page.has_link?("Network", :href => "#network")
    assert page.has_link?("Operating System", :href => "#os")
    assert page.has_link?("Parameters", :href => "#params")
    assert page.has_link?("Additional Information", :href => "#info")
  end

  test "show page" do
    visit systems_path
    click_link "my5name.mydomain.net"
    assert page.has_selector?('h1', :text => "my5name.mydomain.net"), "my5name.mydomain.net <h1> tag, but was not found"
    assert page.has_link?("Properties", :href => "#properties")
    assert page.has_link?("Metrics", :href => "#metrics")
    assert page.has_link?("Templates", :href => "#template")
    assert page.has_link?("Edit", :href => "/systems/my5name.mydomain.net/edit")
    assert page.has_link?("Build", :href => "/systems/my5name.mydomain.net/setBuild")
    assert page.has_link?("Run puppet", :href => "/systems/my5name.mydomain.net/puppetrun")
    assert page.has_link?("Delete", :href => "/systems/my5name.mydomain.net")
  end

end
