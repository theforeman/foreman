require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  def setup
    as_admin { @host = FactoryGirl.create(:host, :with_puppet, :managed) }
  end

  before do
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
  end

  after do
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
  end

  test "index page" do
    assert_index_page(hosts_path,"Hosts","New Host")
  end

  test "create new page" do
    assert_new_button(hosts_path,"New Host",new_host_path)
    assert page.has_link?("Host", :href => "#primary")
    assert page.has_link?("Network", :href => "#network")
    assert page.has_link?("Operating System", :href => "#os")
    assert page.has_link?("Parameters", :href => "#params")
    assert page.has_link?("Additional Information", :href => "#info")
  end

  test "show page" do
    visit hosts_path
    click_link @host.fqdn
    assert page.has_selector?('h1', :text => @host.fqdn), "#{@host.fqdn} <h1> tag, but was not found"
    assert page.has_link?("Properties", :href => "#properties")
    assert page.has_link?("Metrics", :href => "#metrics")
    assert page.has_link?("Templates", :href => "#template")
    assert page.has_link?("Edit", :href => "/hosts/#{@host.fqdn}/edit")
    assert page.has_link?("Build", :href => "/hosts/#{@host.fqdn}#review_before_build")
    assert page.has_link?("Run puppet", :href => "/hosts/#{@host.fqdn}/puppetrun")
    assert page.has_link?("Delete", :href => "/hosts/#{@host.fqdn}")
  end

  test "edit page" do
    disable_orchestration  # Avoid DNS errors
    visit hosts_path
    click_link @host.fqdn
    first(:link, "Edit").click
    assert page.has_link?("Cancel", :href => "/hosts/#{@host.fqdn}")
    fill_in "host_name", :with => "rename.#{@host.domain.to_s}"
    assert_submit_button("/hosts/rename.#{@host.domain.to_s}")
    visit hosts_path
    assert page.has_link?("rename.#{@host.domain.to_s}")
  end

end
