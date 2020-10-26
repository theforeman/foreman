require 'integration_test_helper'

class HostgroupIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(hostgroups_path, "Create Host Group", new_hostgroup_path)
    fill_in "hostgroup_name", :with => "staging"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'staging'
  end

  describe 'edit page' do
    setup do
      @hostgroup = FactoryBot.create(:hostgroup)
      visit hostgroups_path
      click_link @hostgroup.name
    end

    test 'changing hostgroup_name' do
      new_hostgroup_name = "#{@hostgroup.name} Old"
      fill_in 'hostgroup_name', with: new_hostgroup_name
      assert_submit_button(hostgroups_path)

      assert page.has_link? new_hostgroup_name
    end
  end

  test 'clones root_pass' do
    group = FactoryBot.create(:hostgroup, :with_rootpass)
    visit clone_hostgroup_path(group)
    assert page.has_link?('Operating System', :href => '#os')
    click_link 'Operating System'
    root_pass = page.find("#hostgroup_root_pass")
    assert_equal group.root_pass, root_pass.value
  end

  test 'clone shows no errors on lookup values' do
    group = FactoryBot.create(:hostgroup, :with_puppetclass)
    FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :path => "hostgroup\ncomment",
                       :puppetclass => group.puppetclasses.first, :overrides => {group.lookup_value_matcher => 'test'})

    visit clone_hostgroup_path(group)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?('#params .has-error')
  end
end
