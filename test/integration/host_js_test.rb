require 'integration_test_helper'
require 'integration/shared/host_finders'

class HostJSTest < IntegrationTestWithJavascript
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

  describe 'edit page' do
    test 'class parameters and overrides are displayed correctly for strings' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                                      :key_type => 'string', :default_value => true,
                                      :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => false})
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "false"
      assert class_params.find("textarea:enabled")
      class_params.find("a[data-tag='remove']").click
      assert class_params.find("textarea:disabled")
      click_button('Submit')
      assert page.has_link?("Edit")

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "true"
      assert class_params.find("textarea:disabled")
      class_params.find("a[data-tag='override']").click
      assert class_params.find("textarea:enabled")
      class_params.find("textarea").set("false")
      click_button('Submit')
      assert page.has_link?("Edit")

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "false"
      assert class_params.find("textarea:enabled")
    end

    test 'can override puppetclass lookup values' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                                      :key_type => 'string', :default_value => "true",
                                      :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => "false"})

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert class_params.has_selector?("a[data-tag='remove']", :visible => :visible)
      assert class_params.has_selector?("a[data-tag='override']", :visible => :hidden)
      assert_equal class_params.find("textarea").value, "false"
      assert class_params.find("textarea:enabled")

      class_params.find("a[data-tag='remove']").click
      assert class_params.has_selector?("a[data-tag='remove']", :visible => :hidden)
      assert class_params.has_selector?("a[data-tag='override']", :visible => :visible)
      assert_equal class_params.find("textarea").value, "true"
      assert class_params.find("textarea:disabled")

      class_params.find("a[data-tag='override']").click
      assert class_params.has_selector?("a[data-tag='remove']", :visible => :visible)
      assert class_params.has_selector?("a[data-tag='override']", :visible => :hidden)
      assert_equal class_params.find("textarea").value, "true"
      assert class_params.find("textarea:enabled")
    end

    test 'correctly override global params' do
      host = FactoryGirl.create(:host)

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_selector?('#inherited_parameters .btn[data-tag=override]')
      page.find('#inherited_parameters .btn[data-tag=override]').click
      assert page.has_no_selector?('#inherited_parameters .btn[data-tag=override]')
      click_button('Submit')
      assert page.has_link?("Edit")

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?('#inherited_parameters .btn[data-tag=override]')
      page.find('#global_parameters_table a[data-original-title="Remove Parameter"]').click
      assert page.has_selector?('#inherited_parameters .btn[data-tag=override]')
    end
  end

  describe "create new host page" do
    test "default primary interface is in the overview table" do
      assert_new_button(hosts_path, "New Host", new_host_path)

      # switch to interfaces tab
      page.find(:link, "Interfaces").click

      # test column content
      assert table.find('td.identifier', :visible => true).has_content?('')
      assert table.find('td.type', :visible => true).has_content?('Interface')
      assert table.find('td.mac', :visible => true).has_content?('')
      assert table.find('td.ip', :visible => true).has_content?('')
      assert table.find('td.fqdn', :visible => true).has_content?('')

      # should have table header and the primar interface row
      assert_equal 2, table.all('tr', :visible => true).count

      # test the tlags are set properly
      assert table.find('td.flags .primary-flag.active')
      assert table.find('td.flags .provision-flag.active')
    end

    test 'choosing a hostgroup overrides other host attributes' do
      original_hostgroup = FactoryGirl.
        create(:hostgroup, :environment => FactoryGirl.create(:environment))
      overridden_hostgroup = FactoryGirl.
        create(:hostgroup, :environment => FactoryGirl.create(:environment))

      visit new_host_path
      select2(original_hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax

      click_on_inherit('environment')
      select2(overridden_hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax

      environment = find("#s2id_host_environment_id .select2-chosen").text
      assert_equal overridden_hostgroup.environment.name, environment
    end

    test 'saves correct values for inherited fields without hostgroup' do
      env = FactoryGirl.create(:environment)
      os = FactoryGirl.create(:ubuntu14_10, :with_associations)
      Nic::Managed.any_instance.stubs(:dns_conflict_detected?).returns(true)
      visit new_host_path

      fill_in 'host_name', :with => 'myhost1'
      select2 env.name, :from => 'host_environment_id'
      click_link 'Operating System'
      wait_for_ajax
      select2 os.architectures.first.name, :from => 'host_architecture_id'
      wait_for_ajax
      select2 os.title, :from => 'host_operatingsystem_id'
      uncheck('host_build')
      wait_for_ajax
      select2 os.media.first.name, :from => 'host_medium_id'
      wait_for_ajax
      select2 os.ptables.first.name, :from => 'host_ptable_id'
      fill_in 'host_root_pass', :with => '12345678'
      click_link 'Interfaces'
      click_button 'Edit'
      select domains(:unuseddomain).name, :from => 'host_interfaces_attributes_0_domain_id'
      fill_in 'host_interfaces_attributes_0_mac', :with => '11:11:11:11:11:11'
      fill_in 'host_interfaces_attributes_0_ip', :with => '1.1.1.1'
      click_button 'Ok' #close interfaces
      #wait for the dialog to close
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop while find(:css, '#interfaceModal', :visible => false).visible?
      end
      click_button 'Submit' #create new host
      wait_for_ajax
      find('#host-show') #wait for host details page

      host = Host::Managed.search_for('name ~ "myhost1"').first
      assert_equal env.name, host.environment.name
    end

    test 'sets fields to "inherit" when hostgroup is selected' do
      env1 = FactoryGirl.create(:environment)
      env2 = FactoryGirl.create(:environment)
      hg = FactoryGirl.create(:hostgroup, :environment => env2)
      os = FactoryGirl.create(:ubuntu14_10, :with_associations)
      disable_orchestration
      visit new_host_path

      fill_in 'host_name', :with => 'myhost1'
      select2 env1.name, :from => 'host_environment_id'
      wait_for_ajax
      select2 hg.name, :from => 'host_hostgroup_id'
      wait_for_ajax
      click_link 'Operating System'
      wait_for_ajax
      select2 os.architectures.first.name, :from => 'host_architecture_id'
      wait_for_ajax
      select2 os.title, :from => 'host_operatingsystem_id'
      uncheck('host_build')
      wait_for_ajax
      select2 os.media.first.name, :from => 'host_medium_id'
      wait_for_ajax
      select2 os.ptables.first.name, :from => 'host_ptable_id'
      fill_in 'host_root_pass', :with => '12345678'
      click_link 'Interfaces'
      click_button 'Edit'
      select domains(:mydomain).name, :from => 'host_interfaces_attributes_0_domain_id'
      wait_for_ajax
      fill_in 'host_interfaces_attributes_0_mac', :with => '11:11:11:11:11:11'
      wait_for_ajax
      fill_in 'host_interfaces_attributes_0_ip', :with => '2.3.4.44'
      wait_for_ajax
      click_button 'Ok'

      #wait for the dialog to close
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop while find(:css, '#interfaceModal', :visible => false).visible?
      end

      wait_for_ajax
      click_button 'Submit' #create new host
      wait_for_ajax
      find('#host-show') #wait for host details page

      host = Host::Managed.search_for('name ~ "myhost1"').first
      assert_equal env2.name, host.environment.name
    end
  end

  describe "hosts index multiple actions" do
    test 'show action buttons' do
      visit hosts_path
      page.find('#check_all').click

      # Ensure all hosts are checked
      assert page.find('input.host_select_boxes').checked?

      # Dropdown visible?
      assert multiple_actions_div.find('.dropdown-toggle').visible?
      multiple_actions_div.find('.dropdown-toggle').click
      assert multiple_actions_div.find('ul').visible?

      # Hosts are added to cookie
      host_ids_on_cookie = JSON.parse(CGI.unescape(page.driver.cookies['_ForemanSelectedhosts'].value))
      assert(host_ids_on_cookie.include? @host.id)

      # Open modal box
      within('#submit_multiple') do
        click_on('Change Environment')
      end
      assert index_modal.visible?, "Modal window was shown"
      page.find('#environment_id').find("option[value='#{@host.environment_id}']").select_option

      # remove hosts cookie on submit
      index_modal.find('.btn-primary').trigger('click')
      assert_empty(page.driver.cookies['_ForemanSelectedhosts'])
      assert has_selector?("div", :text => "Updated hosts: changed environment")
    end
  end

  describe 'edit page' do
    test 'fields are not inherited on edit' do
      env1 = FactoryGirl.create(:environment)
      env2 = FactoryGirl.create(:environment)
      hg = FactoryGirl.create(:hostgroup, :environment => env2)
      host = FactoryGirl.create(:host, :with_puppet, :hostgroup => hg)
      visit edit_host_path(host)

      select2 env1.name, :from => 'host_environment_id'
      wait_for_ajax

      click_button 'Submit' #create new host
      find_link 'YAML' #wait for host details page

      host.reload
      assert_equal env1.name, host.environment.name
    end

    test 'choosing a hostgroup does not override other host attributes' do
      original_hostgroup = FactoryGirl.
        create(:hostgroup, :environment => FactoryGirl.create(:environment))

      # Make host inherit hostgroup environment
      @host.attributes = @host.apply_inherited_attributes(
        'hostgroup_id' => original_hostgroup.id)
      @host.save

      overridden_hostgroup = FactoryGirl.
        create(:hostgroup, :environment => FactoryGirl.create(:environment))

      visit edit_host_path(@host)
      select2(original_hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax

      click_on_inherit('environment')
      select2(overridden_hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax

      environment = find("#s2id_host_environment_id .select2-chosen").text
      assert_equal original_hostgroup.environment.name, environment
    end

    test 'class parameters and overrides are displayed correctly for booleans' do
      host = FactoryGirl.create(:host, :with_puppetclass)
      lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
                                      :key_type => 'boolean', :default_value => 'false',
                                      :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => 'false'})
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert class_params.has_selector?("a[data-tag='remove']", :visible => :visible)
      assert class_params.has_selector?("a[data-tag='override']", :visible => :hidden)
      assert_equal find("#s2id_host_lookup_values_attributes_#{lookup_key.id}_value .select2-chosen").text, "false"
      select2 "true", :from => "host_lookup_values_attributes_#{lookup_key.id}_value"
      click_button('Submit')

      assert page.has_link?("Edit")
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal find("#s2id_host_lookup_values_attributes_#{lookup_key.id}_value .select2-chosen").text, "true"
      click_button('Submit')
    end
  end

  describe "NIC modal window" do
    describe "editing interfaces" do
      test "click on edit opens modal" do
        go_to_interfaces_tab

        # edit the primary interface
        table.first(:button, 'Edit').click

        assert modal.find('.modal-content').visible?, "Modal window was shown"
        assert modal.find('.interface_primary').checked?, "Primary checkbox is checked"
        assert modal.find('.interface_provision').checked?, "Provision checkbox is checked"

        modal.find(:button, "Cancel").click

        # test column content
        assert table.find('td.identifier').has_content?('')
        assert table.find('td.type').has_content?('Interface')
        assert table.find('td.mac').has_content?('')
        assert table.find('td.ip').has_content?('')
        assert table.find('td.fqdn').has_content?('')
      end

      test "ok button updates overview table" do
        go_to_interfaces_tab

        # edit the primary interface
        table.first(:button, 'Edit').click

        modal.find('.interface_identifier').set('eth0')
        modal.find('.interface_mac').set('11:22:33:44:55:66')
        modal.find('.interface_ip').set('10.32.8.3')
        modal.find('.interface_name').set('name')

        modal.find(:button, "Ok").click

        assert table.find('td.identifier').has_content?('eth0')
        assert table.find('td.type').has_content?('Interface')
        assert table.find('td.mac').has_content?('11:22:33:44:55:66')
        assert table.find('td.ip').has_content?('10.32.8.3')
        assert table.find('td.fqdn').has_content?('')
      end
    end

    describe "adding interfaces" do
      test "click on add opens modal" do
        go_to_interfaces_tab

        assert_interface_change(0) do
          page.find(:button, '+ Add Interface').click

          assert modal.find('.modal-content').visible?, "Modal window was shown"
          refute modal.find('.interface_primary').checked?, "Primary checkbox is unchecked by default"
          refute modal.find('.interface_provision').checked?, "Provision checkbox is unchecked by default"

          modal.find(:button, "Cancel").click
        end
      end

      test "ok button adds new interface" do
        go_to_interfaces_tab

        assert_interface_change(1) do
          page.find(:button, '+ Add Interface').click
          modal.find(:button, "Ok").click
        end
      end

      test "setting primary updates host name" do
        go_to_interfaces_tab

        # edit the primary interface
        table.first(:button, 'Edit').click

        domain = domains(:mydomain)

        modal.find('.interface_name').set('name')
        modal.find('.interface_domain').select(domain.name)

        subnet_and_domain_are_selected(modal, domain)

        modal.find(:button, "Ok").click

        assert table.find('td.fqdn').has_content?('name.'+domain.name)
        assert page.find('#hostFQDN').has_content?('| name.'+domain.name)

        page.find(:link, "Host").click
        assert_equal 'name', page.find('#host_name', :visible => false).value
      end

      test "selecting domain updates subnet list" do
        disable_orchestration
        go_to_interfaces_tab

        table.first(:button, 'Edit').click

        domain = domains(:mydomain)
        modal.find('.interface_domain').select(domain.name)
        subnet_and_domain_are_selected(modal, domain)

        subnet_id = modal.find('#host_interfaces_attributes_0_subnet_id',
                   :visible => false).value
        subnet_label = modal.find('span#select2-chosen-40').text

        assert_equal domain.subnets.first.id.to_s, subnet_id
        assert_equal domain.subnets.first.to_label, subnet_label
      end
    end

    describe "switching flags from the overview table" do
      test "switch primary" do
        go_to_interfaces_tab
        add_interface

        flag_cols = table.all('td.flags')
        flag_cols[1].find('.primary-flag').click

        # only one flag switcher is active
        table.has_css?('.primary-flag.active', :count => 1)

        assert flag_cols[0].has_no_css?('.primary-flag.active'), "First interface's flag is inactive"
        assert flag_cols[1].has_css?('.primary-flag.active'), "New interface's flag is active"
      end

      test "switch provisioning" do
        go_to_interfaces_tab
        add_interface

        flag_cols = table.all('td.flags')
        flag_cols[1].find('.provision-flag').click

        # only one flag switcher is active
        table.has_css?('.provision-flag.active', :count => 1)

        assert flag_cols[0].has_no_css?('.provision-flag.active'), "First interface's flag is inactive"
        assert flag_cols[1].has_css?('.provision-flag.active'), "New interface's flag is active"
      end
    end

    describe "removing interfaces" do
      test "remove interface" do
        go_to_interfaces_tab
        add_interface

        assert_interface_change(-1) do
          table.all(:button, "Delete").last.click
        end
      end
    end
  end

  private

  def subnet_and_domain_are_selected(modal, domain)
    modal.has_select?('host_interfaces_attributes_0_subnet_id',
                      :visible => false,
                      :options => domain.subnets.map(&:to_label))
    modal.has_select?('host_interfaces_attributes_0_domain_id',
                      :visible => false,
                      :selected => domain.name)
  end
end
