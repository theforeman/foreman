require 'test_helper'

class HostgroupIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(hostgroups_path,"Host Groups","New Host Group")
  end

  test "create new page" do
    assert_new_button(hostgroups_path,"New Host Group",new_hostgroup_path)
    fill_in "hostgroup_name", :with => "staging"
    select "production", :from => "hostgroup_environment_id"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'staging'
  end

  test "edit page" do
    visit hostgroups_path
    click_link "db"
    fill_in "hostgroup_name", :with => "db Old"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'db Old'
  end

  test 'edit shows errors on invalid lookup values' do
    group = FactoryGirl.create(:hostgroup, :with_puppetclass)
    FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                       :key_type => 'boolean', :default_value => true,
                       :puppetclass => group.puppetclasses.first, :overrides => {group.lookup_value_matcher => false})

    visit edit_hostgroup_path(group)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?('#params .input-group.has-error')
    fill_in 'hostgroup_lookup_values_attributes_0_value', :with => 'invalid'
    click_button('Submit')
    assert page.has_selector?('#params td.has-error')
  end

  test 'clone shows no errors on lookup values' do
    group = FactoryGirl.create(:hostgroup, :with_puppetclass)
    FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                       :puppetclass => group.puppetclasses.first, :overrides => {group.lookup_value_matcher => 'test'})

    visit clone_hostgroup_path(group)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?('#params tr.has-error')
  end
end
