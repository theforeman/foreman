require 'integration_test_helper'

class HostgroupJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   HostgroupJSTest.test_0001_submit updates taxonomy
  extend Minitest::OptionalRetry

  test 'creates a hostgroup with provisioning data' do
    env = FactoryGirl.create(:environment)
    os = FactoryGirl.create(:ubuntu14_10, :with_associations)
    visit new_hostgroup_path

    fill_in 'hostgroup_name', :with => 'myhostgroup1'
    select2 env.name, :from => 'hostgroup_environment_id'
    click_link 'Operating System'
    wait_for_ajax
    select2 os.architectures.first.name, :from => 'hostgroup_architecture_id'
    wait_for_ajax
    select2 os.title, :from => 'hostgroup_operatingsystem_id'
    wait_for_ajax
    select2 os.media.first.name, :from => 'hostgroup_medium_id'
    wait_for_ajax
    select2 os.ptables.first.name, :from => 'hostgroup_ptable_id'
    fill_in 'hostgroup_root_pass', :with => '12345678'
    assert_submit_button(new_hostgroup_path)
    wait_for_ajax

    host = Hostgroup.where(:name => "myhostgroup1").first
    assert host
    assert_equal env.name, host.environment.name
  end

  describe 'edit form' do
    setup do
      @hostgroup = FactoryGirl.create(:hostgroup, :with_puppetclass)
      @another_puppetclass = FactoryGirl.create(:puppetclass)
    end

    context 'puppet classes are not available in the environment' do
      setup do
        @hostgroup.puppetclasses << @another_puppetclass
        visit edit_hostgroup_path(@hostgroup)
      end

      describe 'Puppet classes tab' do
        test 'it shows a warning' do
          click_link 'Puppet Classes'
          wait_for_ajax

          assert page.has_selector?('#puppetclasses_unavailable_warning')
        end

        test 'it marks selected classes as unavailable' do
          click_link 'Puppet Classes'
          wait_for_ajax

          assert page.has_selector?('.selected_puppetclass.unavailable')
        end
      end
    end
  end

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
    page.find(:xpath, "//div[@id='ms-#{list_id}']//li/span[text() = '#{item.name}']").click
  end
end
