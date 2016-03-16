require 'integration_test_helper'
require 'integration/shared/host_finders'

class HostIntegrationTest < ActionDispatch::IntegrationTest
  include HostFinders

  before do
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
    as_admin { @host = FactoryGirl.create(:host, :with_puppet, :managed) }
  end

  after do
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
  end

  test "index page" do
    assert_index_page(hosts_path,"Hosts","New Host")
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

  describe "create new host page" do
    test "tabs are present" do
      assert_new_button(hosts_path,"New Host",new_host_path)
      assert page.has_link?("Host", :href => "#primary")
      assert page.has_link?("Interfaces", :href => "#network")
      assert page.has_link?("Operating System", :href => "#os")
      assert page.has_link?("Parameters", :href => "#params")
      assert page.has_link?("Additional Information", :href => "#info")
    end
  end

  test "destroy redirects to hosts index" do
    disable_orchestration  # Avoid DNS errors
    visit hosts_path
    click_link @host.fqdn
    assert page.has_link?("Delete", :href => "/hosts/#{@host.fqdn}")
    first(:link, "Delete").click
    assert_current_path hosts_path
  end

  describe 'edit page' do
    test 'correctly show hash type overrides' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param,
                         :with_override, :key_type => 'hash',
                         :default_value => 'a: b',
                         :puppetclass => host.puppetclasses.first,
                         :overrides => { host.lookup_value_matcher => 'a: c' } )

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "a: c\n"
    end

    test 'shows errors on invalid lookup values' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                                      :key_type => 'real', :default_value => true,
                                      :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => false})

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?('#params td.has-error')

      fill_in "host_lookup_values_attributes_#{lookup_key.id}_value", :with => 'invalid'
      click_button('Submit')
      assert page.has_selector?('#params td.has-error')
    end
  end

  describe 'clone page' do
    test 'clones lookup values' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                                      :puppetclass => host.puppetclasses.first)
      lookup_value = LookupValue.create(:value => 'abc', :match => host.lookup_value_matcher, :lookup_key_id => lookup_key.id)

      visit clone_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      a = page.find("#host_lookup_values_attributes_#{lookup_key.id}_value")
      assert_equal lookup_value.value, a.value
    end

    test 'shows no errors on lookup values' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                         :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => 'test'})

      visit clone_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?('#params .has-error')
    end
  end
end
