require 'integration_test_helper'

class HostgroupIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(hostgroups_path, "Create Host Group", new_hostgroup_path)
    fill_in "hostgroup_name", :with => "staging"
    select "production", :from => "hostgroup_environment_id"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'staging'
  end

  describe 'edit page' do
    setup do
      @another_environment = FactoryBot.create(:environment)
      @hostgroup = FactoryBot.create(:hostgroup, :with_puppetclass)
      visit hostgroups_path
      click_link @hostgroup.name
    end

    test 'changing hostgroup_name' do
      new_hostgroup_name = "#{@hostgroup.name} Old"
      fill_in 'hostgroup_name', with: new_hostgroup_name
      assert_submit_button(hostgroups_path)

      assert page.has_link? new_hostgroup_name
    end

    describe 'changing the environment' do
      test 'preserves the puppetclasses' do
        puppetclasses = @hostgroup.puppetclasses.all

        select @another_environment.name, from: 'hostgroup_environment_id'
        assert_submit_button(hostgroups_path)

        assert_equal puppetclasses, @hostgroup.puppetclasses.all
      end
    end
  end

  test 'edit shows errors on invalid lookup values' do
    group = FactoryBot.create(:hostgroup, :with_puppetclass)
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
      :key_type => 'integer', :default_value => true, :path => "hostgroup\ncomment",
      :puppetclass => group.puppetclasses.first, :overrides => {group.lookup_value_matcher => false})

    visit edit_hostgroup_path(group)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?('#params .input-group.has-error')
    fill_in "hostgroup_lookup_values_attributes_#{lookup_key.id}_value", :with => 'invalid'
    click_button('Submit')
    assert page.has_selector?('#params td.has-error')
  end

  test 'clones lookup values' do
    group = FactoryBot.create(:hostgroup, :with_puppetclass)
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :path => "hostgroup\ncomment",
                                    :puppetclass => group.puppetclasses.first)
    lookup_value = LookupValue.create(:value => 'abc', :match => group.lookup_value_matcher, :lookup_key_id => lookup_key.id)

    visit clone_hostgroup_path(group)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    a = page.find("#hostgroup_lookup_values_attributes_#{lookup_key.id}_value")
    assert_equal lookup_value.value, a.value
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
