require 'integration_test_helper'

class HostgroupJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   HostgroupJSTest.test_0001_submit updates taxonomy
  test "index page" do
    assert_index_page(hostgroups_path, "Host Groups", "Create Host Group")
  end

  test 'creates a hostgroup with provisioning data' do
    env = FactoryBot.create(:environment)
    os = FactoryBot.create(:ubuntu14_10, :with_associations)
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
    click_button 'Submit'

    host = Hostgroup.where(:name => "myhostgroup1").first
    assert host
    assert_equal env.name, host.environment.name
    assert page.has_current_path? hostgroups_path
  end

  describe 'edit form' do
    setup do
      @hostgroup = FactoryBot.create(:hostgroup, :with_puppetclass)
      @another_puppetclass = FactoryBot.create(:puppetclass)
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

  describe 'with parent hostgroup' do
    setup do
      @hostgroup = hostgroups(:inherited)
    end

    describe 'edit' do
      test 'explicit pxe loader' do
        explicit_pxe_loader = @hostgroup.operatingsystem.available_loaders.last
        visit edit_hostgroup_path(@hostgroup)

        click_link 'Operating System'
        wait_for_ajax
        select2 explicit_pxe_loader, :from => 'hostgroup_pxe_loader'
        wait_for_ajax

        click_button 'Submit'
        wait_for_ajax

        assert_equal explicit_pxe_loader, @hostgroup.reload.pxe_loader
      end
    end
  end

  test 'submit updates taxonomy' do
    group = FactoryBot.create(:hostgroup, :with_puppetclass)
    new_location = FactoryBot.create(:location)

    visit edit_hostgroup_path(group)
    page.find(:css, "a[href='#locations']").click
    select_from_list 'hostgroup_location_ids', new_location

    click_button "Submit"
    # wait for submit to finish
    page.find('#search-bar')

    group.locations.reload

    assert_includes group.locations, new_location
  end

  test 'parameters change after parent update' do
    group = FactoryBot.create(:hostgroup)
    group.group_parameters << GroupParameter.create(:name => "x", :value => "original")
    child = FactoryBot.create(:hostgroup)

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

  describe 'Puppet Classes tab' do
    context 'has inherited Puppetclasses' do
      setup do
        @hostgroup = FactoryBot.create(:hostgroup, :with_puppetclass)
        @child_hostgroup = FactoryBot.create(:hostgroup, parent: @hostgroup)

        visit edit_hostgroup_path(@child_hostgroup)
        page.find(:link, 'Puppet Classes', href: '#puppet_klasses').click
      end

      test 'it mentions the parent hostgroup by name in the tooltip' do
        page.find('#puppet_klasses .panel h3 a').click
        class_element = page.find('#inherited_ids>li')

        assert_equal @hostgroup.puppetclasses.first.name, class_element.text
      end

      test 'it shows a header mentioning the hostgroup inherited from' do
        header_element = page.find('#puppet_klasses .panel h3 a')
        assert header_element.text =~ /#{@hostgroup.name}$/
      end
    end
  end

  private

  def select_from_list(list_id, item)
    page.find(:xpath, "//div[@id='ms-#{list_id}']//li/span[text() = '#{item.name}']").click
  end
end
