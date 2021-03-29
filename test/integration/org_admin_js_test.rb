require 'integration_test_helper'

class OrgAdminJSTest < IntegrationTestWithJavascript
  setup do
    @org1 = FactoryBot.create(:organization)
    @org2 = FactoryBot.create(:organization)
    @org3 = FactoryBot.create(:organization)
    @loc1 = FactoryBot.create(:location)
    @loc2 = FactoryBot.create(:location)
    @loc3 = FactoryBot.create(:location)
    @user = FactoryBot.create(:user, :password => 'changeme', :mail => 'test@example.com', :organizations => [], :locations => [])

    # to have real Org admin role
    # TODO would be better as part of test setup, it's slow
    load File.join(Rails.root, '/db/seeds.d/030-permissions.rb')
    load File.join(Rails.root, '/db/seeds.d/040-roles.rb')
    @org_admin = Role.find_by_name('Organization admin')

    @org_admin_of_org1 = clone_role(@org_admin, @org1)
  end

  context "user is org admin of single org" do
    def setup
      @user.organizations << @org1
      @user.locations = [@loc1, @loc2]
      @user.roles << @org_admin_of_org1
      @visible_domain = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @invisible_domain_1 = FactoryBot.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_2 = FactoryBot.create(:domain, :organizations => [@org2], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_3 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc3])
      @invisible_domain_4 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [])
    end

    def test_org_admins_can_work_with_resources_in_their_organization
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit domains_path
      wait_for_ajax
      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Locations')
      within('#ms-domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      switch_form_tab('Organizations')
      within('#ms-domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_no_content? @org2.name
        assert page.has_no_content? @org3.name

        # current organization is selected
        within('.ms-selection') do
          assert page.has_content? @org1.name
        end
      end

      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_3.name)
        assert page.has_no_content?(@invisible_domain_4.name)
      end
    end

    def test_org_admin_tries_to_create_domain_when_unselect_the_organization
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit new_domain_path
      wait_for_ajax

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Locations')
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      switch_form_tab('Organizations')
      ensure_selected_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      page.click_button 'Submit'

      created_domain = Domain.unscoped.find_by_name(domain.name)
      # sets the only organization anyway
      assert_equal [@org1], created_domain.organizations
    end

    def test_org_admins_can_not_assign_location_which_they_do_not_belong_to
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit new_domain_path
      wait_for_ajax

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
      switch_form_tab('Organizations')
      ensure_selected_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')

      # once selection are driven by permissions only, this should not be possible
      switch_form_tab('Locations')
      select_option_of_multiselect(@loc3.name, select_id: 'domain_location_ids')
      page.click_button 'Submit'

      # this is partly buggy behavior based on fact user does not belong to location
      # but has view + assign locations permission, this test describe this behavior
      # which should change once org/loc selection is based on permissions entirely
      assert page.has_content?("don't have access to specified organizations or locations")
    end
  end

  context "user is org admin of two organizations" do
    def setup
      @user.organizations = [@org1, @org2]
      @user.locations = [@loc1, @loc2]
      @org_admin_of_org2 = clone_role(@org_admin, @org2)
      @user.roles = [@org_admin_of_org1, @org_admin_of_org2]
      @visible_domain_1 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @visible_domain_2 = FactoryBot.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryBot.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    def test_org_admins_can_work_with_resources_in_their_organization
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit domains_path
      wait_for_ajax

      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Organizations')
      within('#ms-domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_no_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('.ms-selection span')
      end
      select_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      select_option_of_multiselect(@org2.name, select_id: 'domain_organization_ids')

      switch_form_tab('Locations')
      within('#ms-domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org1.name)
      wait_for_ajax

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_no_content?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org2.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_no_content?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end
    end

    def test_org_admin_tries_to_create_resource_without_organization_selection
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit new_domain_path
      wait_for_ajax

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Locations')
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      page.click_button 'Submit'

      assert page.has_content?("Invalid organizations selection, you must select at least one of yours and have 'assign_organizations' permission")
    end
  end

  context "user is org admin of two organizations through single role" do
    def setup
      @user.organizations = [@org1, @org2]
      @user.locations = [@loc1, @loc2]
      @org_admin_of_org_1_and_2 = clone_role(@org_admin, @org1, " and #{@org2.name}")
      @org_admin_of_org_1_and_2.organization_ids = [@org1.id, @org2.id]
      @org_admin_of_org_1_and_2.save # trigger filter inheritance

      @user.roles = [@org_admin_of_org_1_and_2]
      @visible_domain_1 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @visible_domain_2 = FactoryBot.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryBot.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    def test_org_admins_of_two_orgs_can_work_with_resources_in_their_organizations
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit domains_path
      wait_for_ajax

      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Organizations')
      within('#ms-domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_no_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('option[selected="selected"]')
      end
      select_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      select_option_of_multiselect(@org2.name, select_id: 'domain_organization_ids')

      switch_form_tab('Locations')
      within('#ms-domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org1.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_no_content?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org2.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_no_content?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end
    end
  end

  context "user is org admin of three organizations through single role but belongs to only two of them" do
    def setup
      @user.organizations = [@org1, @org3]
      @user.locations = [@loc1, @loc2]
      @org_admin_of_org_123 = clone_role(@org_admin, @org1, " and #{@org2.name} and #{@org3.name}")
      @org_admin_of_org_123.organization_ids = [@org1.id, @org2.id, @org3.id]
      @org_admin_of_org_123.save # trigger filter inheritance
      @user.roles = [@org_admin_of_org_123]
      @visible_domain_1 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc1])
      # visible through permissions, can't be switched to though
      @visible_domain_2 = FactoryBot.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryBot.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    # this test illustrate the inconsistency results where user can assign resource to org but he/she can't
    # switch to that org context so after assignment, the resource is not visible, assign_organizations defines
    # what organizations can be assigned
    def test_org_admins_can_assign_resources_to_both_orgs_but_cant_switch_to_its_context
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit domains_path
      wait_for_ajax

      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Locations')
      within('#ms-domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      switch_form_tab('Organizations')
      within('#ms-domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('option[selected="selected"]')
      end
      # select_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      select_option_of_multiselect(@org2.name, select_id: 'domain_organization_ids')

      page.click_button 'Submit'

      # choosing only org that user does not belong to is forbidden
      assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified organizations or locations")

      switch_form_tab('Organizations')
      # with org1 which user belongs to, submit passes but the organization selection is limited to user's list
      select_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
      end

      select_organization(@org3.name)
      within "#domains_list" do
        assert page.has_no_content?(domain.name)
      end

      refute_available_organization(@org2.name)

      select_organization(@org1.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
      end

      within "#domains_list" do
        page.click_link domain.name
      end
    end
  end

  context "user is org admin of two organizations but is not assigned to any organization" do
    def setup
      @user.organizations = []
      @user.locations = [@loc1, @loc2]
      @org_admin_of_org2 = clone_role(@org_admin, @org2)
      @user.roles = [@org_admin_of_org1, @org_admin_of_org2]
      @invisible_domain_1 = FactoryBot.create(:domain, :organizations => [@org1], :locations => [@loc1])
    end

    # this test illustrate the non-user without any organization assigned, they can't list or create anything
    # but because of restrictions coming both from Taxonomix and Authorizable. Taxonomix prevents listing while
    # Authorizable prevents creation. The information leaks through form, thanks to assign_organizations, names
    # of organizations in form are visible
    def test_org_admins_can_assign_resources_to_both_orgs_but_cant_switch_to_its_context
      login_user(@user.login, 'changeme')
      wait_for_ajax
      visit domains_path
      wait_for_ajax

      assert page.has_no_content?(@invisible_domain_1.name)
      refute_available_organization(@org1.name)
      refute_available_organization(@org2.name)

      page.find('a', text: 'Create Domain').click

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      domain = FactoryBot.build_stubbed(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      switch_form_tab('Locations')
      select_option_of_multiselect(@loc1.name, select_id: 'domain_location_ids')
      select_option_of_multiselect(@loc2.name, select_id: 'domain_location_ids')

      switch_form_tab('Organizations')
      within('#ms-domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
      end
      select_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      select_option_of_multiselect(@org2.name, select_id: 'domain_organization_ids')
      page.click_button 'Submit'

      # choosing only org that user does not belong to is forbidden
      assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified organizations or locations")

      switch_form_tab('Organizations')
      # with org1 which user belongs to, submit passes but the organization selection is limited to user's list
      deselect_option_of_multiselect(@org1.name, select_id: 'domain_organization_ids')
      deselect_option_of_multiselect(@org2.name, select_id: 'domain_organization_ids')
      page.click_button 'Submit'

      # can't create in any context either
      assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified organizations or locations")
    end
  end

  def clone_role(original, org, suffix = '')
    new_role = original.clone
    new_role.name = "#{original.name} of #{org.name}#{suffix}"
    new_role.builtin = 0
    new_role.organization_ids = [org.id]
    new_role.save!
    new_role
  end

  def ensure_selected_option_of_multiselect(label, select_id: nil)
    selected = page.find("#ms-#{select_id} .ms-selection").has_content?(label)
    selected || select_option_of_multiselect(label, select_id: select_id)
  end

  def select_option_of_multiselect(label, select_id: nil)
    page.find("#ms-#{select_id} .ms-selectable").find('span', text: label).click
  end

  def deselect_option_of_multiselect(label, select_id: nil)
    page.find("#ms-#{select_id} .ms-selection").find('span', text: label).click
  end
end
