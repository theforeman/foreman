require 'integration_test_helper'
require 'integration/shared/host_finders'

class HostIntegrationTest < ActionDispatch::IntegrationTest
  include HostFinders

  before do
    as_admin { @host = FactoryBot.create(:host, :with_puppet, :managed) }
  end

  test "index page with search" do
    visit hosts_path(search: "name = #{@host.name}")
    assert page.has_link?('Export', href: hosts_path(format: 'csv', search: "name = #{@host.name}"))
  end

  describe "create new host page" do
    test "tabs are present" do
      assert_new_button(hosts_path, "Create Host", new_host_path)
      assert page.has_link?("Host", :href => "#primary")
      assert page.has_link?("Interfaces", :href => "#network")
      assert page.has_link?("Operating System", :href => "#os")
      assert page.has_link?("Parameters", :href => "#params")
      assert page.has_link?("Additional Information", :href => "#info")
    end
  end

  test "destroy redirects to hosts index" do
    disable_orchestration # Avoid DNS errors
    visit hosts_path
    click_link @host.fqdn
    assert page.has_link?("Delete", :href => "/hosts/#{@host.fqdn}")
    first(:link, "Delete").click
    assert_current_path hosts_path
  end

  describe 'edit page' do
    test 'displays warning when vm not found by uuid' do
      ComputeResource.any_instance.stubs(:find_vm_by_uuid).raises(ActiveRecord::RecordNotFound)
      host = FactoryBot.create(:host, :with_hostgroup, :with_environment, :on_compute_resource, :managed)

      visit edit_host_path(host)
      assert page.has_link?('Operating System')
      click_link 'Operating System'

      alert_header = page.find('#compute_resource div.alert strong')
      alert_body = page.find('#compute_resource div.alert span.text')

      assert_equal "'#{host.name}' not found on '#{host.compute_resource}'", alert_header.text
      assert_equal "'#{host.name}' could be deleted or '#{host.compute_resource}' is not responding.", alert_body.text
    end
  end

  describe 'clone page' do
    test 'shows no errors on lookup values' do
      host = FactoryBot.create(:host, :with_puppetclass)
      FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :path => "fqdn\ncomment",
                         :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => 'test'})

      visit clone_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?('#params .has-error')
    end

    test 'clones root_pass' do
      host = FactoryBot.create(:host, :managed)
      visit clone_host_path(host)
      assert page.has_link?('Operating System', :href => '#os')
      click_link 'Operating System'
      root_pass = page.find("#host_root_pass")
      assert_equal host.root_pass, root_pass.value
    end

    test 'build mode is enabled for managed hosts' do
      host = FactoryBot.create(:host, :managed)
      visit clone_host_path(host)
      assert page.has_checked_field?('host_build')
    end

    test 'build mode is not enabled for unmanaged hosts' do
      host = FactoryBot.create(:host)
      visit clone_host_path(host)
      assert page.has_no_checked_field?('host_build')
    end
  end
end
