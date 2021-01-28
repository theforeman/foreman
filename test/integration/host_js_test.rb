require 'integration_test_helper'
require 'integration/shared/host_finders'
require 'integration/shared/host_orchestration_stubs'

class HostJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   HostJSTest::edit page.test_0003_correctly override global params
  #   HostJSTest::create new host page.test_0003_saves correct values for inherited fields without hostgroup
  #   HostJSTest::NIC modal window::adding interfaces.test_0006_selecting type updates interface fields
  #   HostJSTest::NIC modal window::adding interfaces.test_0002_ok button adds new interface
  #   HostJSTest::NIC modal window::adding interfaces.test_0003_setting primary updates host name
  #   HostJSTest::NIC modal window::adding interfaces.test_0005_selecting domain updates puppetclass parameters
  #   HostJSTest::NIC modal window::adding interfaces.test_0004_selecting domain updates subnet list
  #   HostJSTest::NIC modal window::adding interfaces.test_0001_click on add opens modal

  include HostFinders
  include HostOrchestrationStubs

  before do
    as_admin { @host = FactoryBot.create(:host, :with_puppet, :managed) }
    Fog.mock!
  end

  after do
    Fog.unmock!
  end

  describe "show page" do
    test "has proper title and links" do
      visit hosts_path
      click_link @host.fqdn
      assert_breadcrumb_text(@host.fqdn)
      assert page.has_link?("Properties", :href => "#properties")
      assert page.has_link?("Metrics", :href => "#metrics")
      assert page.has_link?("Templates", :href => "#template")
      assert page.has_link?("Edit", :href => "/hosts/#{@host.fqdn}/edit")
      assert page.has_link?("Build", :href => "/hosts/#{@host.fqdn}#review_before_build")
      assert page.has_link?("Delete", :href => "/hosts/#{@host.fqdn}")
    end

    test "link to specific tab in show page" do
      host = FactoryBot.create(:host)

      visit "#{host_path(host)}#metrics"
      wait_for_ajax

      page.assert_selector('#host-show-tabs li.active', count: 1, text: "Metrics")
      page.assert_selector('#host-show-tabs-content div.active', count: 1, text: /No puppet activity/)
    end

    test "default active tab is properties" do
      host = FactoryBot.create(:host)

      visit host_path(host) # not passing the active-tab param here
      wait_for_ajax

      page.assert_selector('#host-show-tabs li.active', count: 1, text: "Properties")
      page.assert_selector('#host-show-tabs-content div.active', count: 1, text: /Properties/)
    end
  end

  describe 'multiple hosts selection' do
    setup do
      @entries = Setting[:entries_per_page]
      FactoryBot.create_list(:host, 2)
    end

    teardown do
      Setting[:entries_per_page] = @entries
    end

    test "index page" do
      assert_index_page(hosts_path, "Hosts", "Create Host")
    end

    test 'hosts counter should refer to per_page value first (max prespective)' do
      Setting[:entries_per_page] = 2
      visit hosts_path(per_page: 3)
      check 'check_all'
      assert page.has_text?(:all, "All 3 hosts on this page are selected")
    end

    test 'hosts counter should refer to per_page value first (min prespective)' do
      Setting[:entries_per_page] = 3
      visit hosts_path(per_page: 2)
      check 'check_all'
      assert page.has_text?(:all, "All 2 hosts on this page are selected")
    end

    test 'hosts counter should refer to setting- entries_per_page when there is no per_page value' do
      Setting[:entries_per_page] = 3
      visit hosts_path()
      check 'check_all'
      assert page.has_text?(:all, "All 3 hosts on this page are selected")
    end

    test 'cookie should exist after checking all, cookie should clear after search' do
      Setting[:entries_per_page] = 3
      visit hosts_path()
      check 'check_all'
      assert_not_nil get_me_the_cookie('_ForemanSelectedhosts')
      visit hosts_path(search: "name = abc")
      assert_nil get_me_the_cookie('_ForemanSelectedhosts')
    end

    test 'bulk select all hosts' do
      Setting[:entries_per_page] = 3
      visit hosts_path(per_page: 2)
      check 'check_all'
      assert page.has_text?(:all, "Select all 3 hosts")
      find('#multiple-alert > .text > a').click
      assert page.has_text?(:all, "All 3 hosts are selected")
    end

    test 'apply bulk action, change environment on all hosts' do
      Setting[:entries_per_page] = 3
      visit hosts_path(per_page: 2)
      check 'check_all'
      find('#multiple-alert > .text > a').click
      find('#submit_multiple').click
      find("a", :text => /\AChange Environment\z/).click
      find('#environment_id').find(:xpath, 'option[4]').select_option
      find("button", :text => /\ASubmit\z/).click
      assert page.has_text?(:all, "Updated hosts: changed environment")
    end
  end

  describe 'edit page' do
    test 'class parameters and overrides are displayed correctly for strings' do
      host = FactoryBot.create(:host, :with_puppetclass)
      FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
        :key_type => 'string', :default_value => true, :path => "fqdn",
        :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => false})
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "false"
      assert class_params.find("textarea:enabled")
      class_params.find("a[data-tag='remove']").click
      assert class_params.find("textarea:disabled")
      click_on_submit

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "true"
      assert class_params.find("textarea:disabled")
      class_params.find("a[data-tag='override']").click
      assert class_params.find("textarea:enabled")
      class_params.find("textarea").set("false")
      click_on_submit

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal class_params.find("textarea").value, "false"
      assert class_params.find("textarea:enabled")
    end

    test 'can override puppetclass lookup values' do
      host = FactoryBot.create(:host, :with_puppetclass)
      FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
        :key_type => 'string', :default_value => "true", :path => "fqdn",
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
      host = FactoryBot.create(:host)

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      id = '#override-param-test' # the global param fixture override button
      assert page.has_selector?(id)
      page.find(id).click
      assert page.has_no_selector?(id)
      click_on_submit

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?(id)
      page.find('#global_parameters_table a[data-original-title="Remove Parameter"]').click
      assert page.has_selector?(id)
    end
  end

  describe "create new host page" do
    test "default primary interface is in the overview table" do
      assert_new_button(hosts_path, "Create Host", new_host_path)

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
      original_hostgroup = FactoryBot.
        create(:hostgroup, :environment => FactoryBot.create(:environment))
      overridden_hostgroup = FactoryBot.
        create(:hostgroup, :environment => FactoryBot.create(:environment))

      visit new_host_path
      select2(original_hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax
      click_on_inherit('environment')
      select2(overridden_hostgroup.name, :from => 'host_hostgroup_id')
      assert page.find('#s2id_host_environment_id .select2-chosen').has_text? overridden_hostgroup.environment.name
    end

    test 'choosing a hostgroup with compute resource works' do
      require 'fog/libvirt/models/compute/node'
      Foreman::Model::Libvirt.any_instance.stubs(:hypervisor).returns(Fog::Libvirt::Compute::Node.new(:cpus => 4))
      hostgroup = FactoryBot.create(:hostgroup, :with_environment, :with_subnet, :with_domain, :with_compute_resource)
      hostgroup.subnet.update!(ipam: IPAM::MODES[:db])
      compute_profile = FactoryBot.create(:compute_profile, :with_compute_attribute, :compute_resource => hostgroup.compute_resource)
      compute_attributes = compute_profile.compute_attributes.where(:compute_resource_id => hostgroup.compute_resource.id).first
      compute_attributes.vm_attrs['nics_attributes'] = {'0' => {'type' => 'bridge', 'bridge' => 'test'}}
      compute_attributes.vm_attrs['cpus'] = '2'
      compute_attributes.save

      visit new_host_path
      select2(hostgroup.name, :from => 'host_hostgroup_id')
      wait_for_ajax
      click_link('Virtual Machine')
      cpus_field = page.find_field('host_compute_attributes_cpus')
      assert_equal '1', cpus_field.value

      switch_form_tab_to_interfaces
      click_button('Edit')
      ipv4_field = page.find_field('host_interfaces_attributes_0_ip')
      refute_empty ipv4_field.value
      close_interfaces_modal

      find(:css, '#host_tab').click
      click_on_inherit('compute_profile')
      select2(compute_profile.name, :from => 'host_compute_profile_id')

      click_link('Virtual Machine')
      cpus_field = page.find_field('host_compute_attributes_cpus')
      assert_equal '2', cpus_field.value

      switch_form_tab_to_interfaces
      click_button('Edit')
      bridge_field = page.find_field('host_interfaces_attributes_0_compute_attributes_bridge')
      assert_equal 'test', bridge_field.value
    end

    test 'saves correct values for inherited fields without hostgroup' do
      env = FactoryBot.create(:environment)
      os = FactoryBot.create(:ubuntu14_10, :with_associations)
      Nic::Managed.any_instance.stubs(:dns_conflict_detected?).returns(true)
      visit new_host_path

      fill_in 'host_name', :with => 'myhost1'
      select2 'Organization 1', :from => 'host_organization_id'
      wait_for_ajax
      select2 'Location 1', :from => 'host_location_id'
      wait_for_ajax
      select2 env.name, :from => 'host_environment_id'

      click_link 'Operating System'
      wait_for_ajax
      select2 os.architectures.first.name, :from => 'host_architecture_id'
      select2 os.title, :from => 'host_operatingsystem_id'
      uncheck('host_build')
      select2 os.media.first.name, :from => 'host_medium_id'
      select2 os.ptables.first.name, :from => 'host_ptable_id'
      fill_in 'host_root_pass', :with => '12345678'

      switch_form_tab_to_interfaces
      click_button 'Edit'
      select2 domains(:mydomain).name, :from => 'host_interfaces_attributes_0_domain_id'
      fill_in 'host_interfaces_attributes_0_mac', :with => '00:11:11:11:11:11'
      fill_in 'host_interfaces_attributes_0_ip', :with => '1.1.1.1'
      close_interfaces_modal
      click_on_submit
      find('#host-show') # wait for host details page

      host = Host::Managed.search_for('name ~ "myhost1"').first
      assert_equal env.name, host.environment.name
    end

    test 'sets fields to "inherit" when hostgroup is selected' do
      env1 = FactoryBot.create(:environment)
      env2 = FactoryBot.create(:environment)
      hg = FactoryBot.create(:hostgroup, :environment => env2)
      os = FactoryBot.create(:ubuntu14_10, :with_associations)
      disable_orchestration
      visit new_host_path

      fill_in 'host_name', :with => 'myhost1'
      select2 'Organization 1', :from => 'host_organization_id'
      wait_for_ajax
      select2 'Location 1', :from => 'host_location_id'
      wait_for_ajax
      select2 env1.name, :from => 'host_environment_id'
      select2 hg.name, :from => 'host_hostgroup_id'
      wait_for_ajax

      click_link 'Operating System'
      select2 os.architectures.first.name, :from => 'host_architecture_id'
      select2 os.title, :from => 'host_operatingsystem_id'
      uncheck('host_build')

      select2 os.media.first.name, :from => 'host_medium_id'
      select2 os.ptables.first.name, :from => 'host_ptable_id'
      fill_in 'host_root_pass', :with => '12345678'

      switch_form_tab_to_interfaces
      click_button 'Edit'
      select2 domains(:mydomain).name, :from => 'host_interfaces_attributes_0_domain_id'
      fill_in 'host_interfaces_attributes_0_mac', :with => '00:11:11:11:11:11'
      fill_in 'host_interfaces_attributes_0_ip', :with => '2.3.4.44'

      close_interfaces_modal

      click_on_submit

      host = Host::Managed.search_for('name ~ "myhost1"').first
      assert_equal env2.name, host.environment.name
    end

    test 'setting host group updates parameters tab' do
      hostgroup = FactoryBot.create(:hostgroup, :with_parameter)
      visit new_host_path
      select2(hostgroup.name, :from => 'host_hostgroup_id')

      wait_for_ajax

      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'

      assert page.has_selector?("#inherited_parameters #name_#{hostgroup.group_parameters.first.name}")
    end

    test 'new parameters can be edited and removed' do
      role = FactoryBot.create(:role)
      user = FactoryBot.create(:user, :with_mail)
      user.roles << role
      FactoryBot.create(:filter,
        :permissions => Permission.where(:name => ['create_hosts']),
        :role => role)
      FactoryBot.create(:filter,
        :permissions => Permission.where(:name => ['create_params', 'view_params']),
        :role => role)

      FactoryBot.create(:common_parameter, :name => "a_parameter")

      set_request_user(user)

      host = FactoryBot.create(:host, :with_puppetclass)
      FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
        :key_type => 'string', :default_value => true, :path => "fqdn",
        :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => false})

      visit new_host_path
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'

      assert page.has_link? '+ Add Parameter'
      click_link '+ Add Parameter'
      assert page.has_no_css? '#new_host_parameter_value[disabled=disabled]'
      assert page.has_link? 'Remove'
      click_link 'Remove'

      assert page.has_css? 'a#override-param-a_parameter'
      find(:css, 'a#override-param-a_parameter').click

      assert page.has_no_css? '#new_host_parameter_value[disabled=disabled]'
      assert page.has_link? 'Remove'
    end
  end

  describe "hosts index multiple actions" do
    test 'show action buttons' do
      visit hosts_path
      check 'check_all'

      # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
      assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

      # Dropdown visible?
      assert multiple_actions_div.find('.dropdown-toggle').visible?
      multiple_actions_div.find('.dropdown-toggle').click
      assert multiple_actions_div.find('ul').visible?

      # Hosts are added to cookie
      host_ids_on_cookie = JSON.parse(CGI.unescape(get_me_the_cookie('_ForemanSelectedhosts')&.fetch(:value)))
      assert(host_ids_on_cookie.include?(@host.id))

      # Open modal box
      within('#submit_multiple') do
        click_on('Change Environment')
      end
      assert index_modal.visible?, "Modal window was shown"
      page.find('#environment_id').find("option[value='#{@host.environment_id}']").select_option

      # remove hosts cookie on submit
      index_modal.find('.btn-primary').click
      assert_current_path hosts_path
      assert_empty(get_me_the_cookie('_ForemanSelectedhosts'))
    end

    test 'redirect js' do
      visit hosts_path
      check 'check_all'

      # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
      assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

      # Hosts are added to cookie
      host_ids_on_cookie = JSON.parse(CGI.unescape(get_me_the_cookie('_ForemanSelectedhosts')&.fetch(:value)))
      assert(host_ids_on_cookie.include?(@host.id))

      page.execute_script("tfm.hosts.table.buildRedirect('#{select_multiple_environment_hosts_path}')")
      assert_current_path(select_multiple_environment_hosts_path, :ignore_query => true)
    end

    test 'redirect js with parameter in URL' do
      path1 = hosts_path(param1: 'val1')
      path2 = hosts_path(param1: 'val1', param2: 'val2')

      visit hosts_path
      check 'check_all'
      page.execute_script("tfm.hosts.table.buildRedirect('#{path1}')")
      assert(current_url.include?("#{path1}&host_ids"))

      visit hosts_path
      check 'check_all'
      page.execute_script("tfm.hosts.table.buildRedirect('#{path2}')")
      assert(current_url.include?("#{path2}&host_ids"))
    end
  end

  describe 'edit page' do
    test 'fields are not inherited on edit' do
      env1 = FactoryBot.create(:environment)
      env2 = FactoryBot.create(:environment)
      hg = FactoryBot.create(:hostgroup, :environment => env2)
      host = FactoryBot.create(:host, :with_puppet, :hostgroup => hg)
      visit edit_host_path(host)

      select2 env1.name, :from => 'host_environment_id'
      click_on_submit

      host.reload
      assert_equal env1.name, host.environment.name
    end

    test 'user without edit_params permission can save host with params' do
      host = FactoryBot.create(:host, :with_puppetclass)
      FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
        :with_override, :key_type => 'string',
                         :default_value => 'string1', :path => "fqdn\ncomment",
                         :puppetclass => host.puppetclasses.first,
                         :overrides => { host.lookup_value_matcher => 'string2' })
      user = FactoryBot.create(:user, :with_mail)
      user.update_attribute(:roles, roles(:viewer, :edit_hosts))
      refute user.can? 'edit_params'
      set_request_user(user)
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert class_params.find('textarea').disabled?
      assert_equal 2, class_params.all('input:disabled', :visible => :all).count
      assert_equal 0, class_params.all('input\:not[disabled]', :visible => :all).count
      click_button('Submit')
      assert page.has_link?('Edit')
    end

    test 'shows errors on invalid lookup values' do
      host = FactoryBot.create(:host, :with_puppetclass)
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
        :key_type => 'real', :default_value => true, :path => "fqdn\ncomment",
        :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => false})

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_no_selector?('#params td.has-error')

      fill_in "host_lookup_values_attributes_#{lookup_key.id}_value", :with => 'invalid'
      click_button('Submit')
      assert page.has_selector?('#params td.has-error')
    end

    test 'choosing a hostgroup does not override other host attributes' do
      original_hostgroup = FactoryBot.
        create(:hostgroup, :environment => FactoryBot.create(:environment),
                           :puppet_proxy => FactoryBot.create(:puppet_smart_proxy))

      # Make host inherit hostgroup environment
      @host.attributes = @host.apply_inherited_attributes(
        'hostgroup_id' => original_hostgroup.id)
      @host.save

      overridden_hostgroup = FactoryBot.
        create(:hostgroup, :environment => FactoryBot.create(:environment))

      visit edit_host_path(@host)
      select2(original_hostgroup.name, :from => 'host_hostgroup_id')

      assert_equal original_hostgroup.puppet_proxy.name, find('#s2id_host_puppet_proxy_id .select2-chosen').text

      click_on_inherit('puppet_proxy')
      select2(overridden_hostgroup.name, :from => 'host_hostgroup_id')

      assert find('#s2id_host_environment_id .select2-chosen').has_text? original_hostgroup.environment.name

      # On host group change, the disabled select will be reset to an empty value - disabled select2 is invisible on chrome
      assert find('#s2id_host_puppet_proxy_id .select2-chosen', visible: :all).has_text? ''
    end

    test 'class parameters and overrides are displayed correctly for booleans' do
      host = FactoryBot.create(:host, :with_puppetclass)
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
        :key_type => 'boolean', :default_value => 'false', :path => "fqdn",
        :puppetclass => host.puppetclasses.first, :overrides => {host.lookup_value_matcher => 'false'})
      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert class_params.has_selector?("a[data-tag='remove']", :visible => :visible)
      assert class_params.has_selector?("a[data-tag='override']", :visible => :hidden)
      assert_equal find("#s2id_host_lookup_values_attributes_#{lookup_key.id}_value .select2-chosen").text, "false"
      select2 "true", :from => "host_lookup_values_attributes_#{lookup_key.id}_value"
      click_on_submit

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert_equal find("#s2id_host_lookup_values_attributes_#{lookup_key.id}_value .select2-chosen").text, "true"
    end

    test 'changing host group updates parameters tab' do
      hostgroup1, hostgroup2 = FactoryBot.create_pair(:hostgroup, :with_parameter)
      host = FactoryBot.create(:host, :hostgroup => hostgroup1)

      visit edit_host_path(host)
      assert page.has_link?('Parameters', :href => '#params')
      click_link 'Parameters'
      assert page.has_selector?("#inherited_parameters #name_#{hostgroup1.group_parameters.first.name}")

      click_link 'Host'
      select2(hostgroup2.name, :from => 'host_hostgroup_id')

      click_link 'Parameters'
      assert page.has_no_selector?("#inherited_parameters #name_#{hostgroup1.group_parameters.first.name}")
      assert page.has_selector?("#inherited_parameters #name_#{hostgroup2.group_parameters.first.name}")
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
        select2 domain.name, :from => 'host_interfaces_attributes_0_domain_id'

        subnet_and_domain_are_selected(modal, domain)

        modal.find(:button, "Ok").click

        assert table.find('td.fqdn').has_content?('name.' + domain.name)

        click_link('host_tab')
        assert_equal 'name', page.find('#host_name', :visible => false).value
      end

      test "selecting domain updates subnet list" do
        domain = domains(:mydomain)
        disable_orchestration
        go_to_interfaces_tab

        table.first(:button, 'Edit').click
        wait_for_modal
        select2 domain.name, :from => 'host_interfaces_attributes_0_domain_id'
        subnet_and_domain_are_selected(modal, domain)
        assert page.find('#host_interfaces_attributes_0_subnet_id option[selected="selected"]', visible: false).has_text? ""
      end

      test "selecting domain updates puppetclass parameters" do
        disable_orchestration
        domain = FactoryBot.create(:domain)

        host = FactoryBot.create(:host, :with_puppetclass)

        lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :path => "fqdn\ndomain\ncomment",
                                        :puppetclass => host.puppetclasses.first, :default_value => 'default')
        LookupValue.create(:value => 'domain', :match => "domain=#{domain.name}", :lookup_key_id => lookup_key.id)

        visit edit_host_path(host)
        assert page.has_link?('Parameters', :href => '#params')
        click_link 'Parameters'
        assert_equal class_params.find("textarea").value, "default"

        switch_form_tab_to_interfaces
        table.first(:button, 'Edit').click

        select2 domain.name, :from => 'host_interfaces_attributes_0_domain_id'
        modal.find(:button, "Ok").click

        assert page.has_link?('Parameters', :href => '#params')
        click_link 'Parameters'
        assert_equal "domain", class_params.find("textarea").value
      end

      test "selecting type updates interface fields" do
        disable_orchestration
        go_to_interfaces_tab

        table.first(:button, 'Edit').click
        select2 'Bond', :from => 'host_interfaces_attributes_0_type'
        assert page.has_selector? 'input[name="host[interfaces_attributes][0][bond_options]"]'
      end

      test "showing only mac error when entering mac incorrectly" do
        domain = domains(:mydomain)
        subnet = subnets(:one)
        mac = 'bad address'
        disable_orchestration
        go_to_interfaces_tab

        table.first(:button, 'Edit').click
        wait_for_modal
        select2 domain.name, :from => 'host_interfaces_attributes_0_domain_id'
        select2 subnet.name, :from => 'host_interfaces_attributes_0_subnet_id'
        modal.find('.interface_mac').set(mac)
        modal.find('.interface_identifier').set('eth0')
        assert page.has_selector?('span[class="error-message"]', :count => 1)
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
        wait_for do
          flag_cols[1].find('.provision-flag').click
        end

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
          table.first('tr:nth-child(2) td:last-child').find('button', :text => 'Delete').click
        end
      end
    end
  end

  describe 'Puppet Classes tab' do
    context 'has inherited Puppetclasses' do
      setup do
        @hostgroup = FactoryBot.create(:hostgroup, :with_puppetclass)
        @host = FactoryBot.create(:host, hostgroup: @hostgroup, environment: @hostgroup.environment)

        visit edit_host_path(@host)
        page.find(:link, 'Puppet Classes', href: '#puppet_klasses').click
      end

      test 'it mentions the hostgroup by name in the tooltip' do
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

  def switch_form_tab_to_interfaces
    switch_form_tab('Interfaces')
    disable_interface_modal_animation
  end

  def subnet_and_domain_are_selected(modal, domain)
    modal.assert_selector("#interfaceModal #s2id_host_interfaces_attributes_0_domain_id .select2-chosen",
      text: domain.name)
    modal.assert_selector('#interfaceModal #host_interfaces_attributes_0_subnet_id option',
      visible: false,
      count: domain.subnets.count + 1) # plus one empty
    domain.subnets.each do |subnet|
      modal.assert_selector('#interfaceModal #host_interfaces_attributes_0_subnet_id option',
        visible: false,
        text: subnet.to_label)
    end
  end
end
