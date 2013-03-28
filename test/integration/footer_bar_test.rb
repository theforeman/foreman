require 'test_helper'

class FooterBarTest < ActionDispatch::IntegrationTest

  test "footer links" do
    visit root_path
    assert page.has_link?("Ohad Levy", :href => "mailto:ohadlevy@gmail.com")
    assert page.has_link?("Help", :href => "/dashboard/help")
    assert page.has_link?("Wiki", :href => "http://theforeman.org/wiki/foreman")
    assert page.has_link?("Support", :href => "http://theforeman.org/projects/foreman/wiki/Support")
    assert page.has_content?("Version")
  end

end
