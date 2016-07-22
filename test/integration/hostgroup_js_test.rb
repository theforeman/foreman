require 'integration_test_helper'

class HostgroupJSTest < IntegrationTestWithJavascript
  test 'submit updates taxonomy' do
    group = FactoryGirl.create(:hostgroup, :with_puppetclass)
    new_location = FactoryGirl.create(:location)

    visit edit_hostgroup_path(group)
    page.find(:css, "a[href='#locations']").click
    select_from_list 'hostgroup_location_ids', new_location

    click_button "Submit"
    #wait for submit to finish
    page.find('#search-form')

    group.locations.reload

    assert_includes group.locations, new_location
  end

  test 'parameters change after parent update' do
    group = FactoryGirl.create(:hostgroup)
    group.group_parameters << GroupParameter.create(:name => "x", :value => "original")
    child = FactoryGirl.create(:hostgroup)

    visit clone_hostgroup_path(child)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?("#inherited_parameters #name_x")

    click_link 'Hostgroup'
    select2(group.name, :from => 'hostgroup_parent_id')
    wait_for_ajax

    click_link 'Parameters'
    assert page.has_selector?("#inherited_parameters #name_x")
  end

  private

  def select_from_list(list_id, item)
    selector = "//div[@id='ms-#{list_id}']//li/span[text() = '#{item.name}']"
    assert page.has_xpath?(selector, :visible => true)
    page.find(:xpath, selector).click
  end
end
