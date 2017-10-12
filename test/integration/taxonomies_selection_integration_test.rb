require 'integration_test_helper'

class TaxonomiesSelectionIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @organization = FactoryGirl.create(:organization)
    @location = FactoryGirl.create(:location)
  end

  test "admin can login to any context and switch between contexts" do
    set_empty_default_context(users(:admin))
    login_user(users(:admin).login, 'secret')
    assert_current_organization('Any Organization')
    assert_current_location('Any Location')

    select_organization(@organization.name)
    assert_current_organization(@organization.name)

    visit domains_path
    assert_current_organization(@organization.name)
  end

  test "default organization and location is set after login for admin but can be changed to any" do
    set_default_context(users(:admin), @organization, @location)
    login_user(users(:admin).login, 'secret')
    assert_current_organization(@organization.name)
    assert_current_location(@location.name)

    select_organization('Any Organization')
    assert_current_organization('Any Organization')

    visit domains_path
    assert_current_organization('Any Organization')
  end

  context 'under non-admin user' do
    setup do
      @user = FactoryGirl.create(:user, :password => 'changeme', :mail => "user@example.com")
    end

    context 'with single organization' do
      setup do
        @user.update_attributes(:organization_ids => [@organization.id], :location_ids => [@location.id])
      end

      test 'the only taxonomy is always selected even if they explicitly choose any context regardless of default taxonomy' do
        set_empty_default_context(@user)
        login_user(@user.login, 'changeme')
        assert_current_organization(@organization.name)
        assert_current_location(@location.name)

        # switches back to only org that user has
        select_organization('Any Organization')
        assert_current_organization(@organization.name)

        # switches back to only loc that user has
        select_location('Any Location')
        assert_current_location(@location.name)
      end

      test 'default taxonomy works the same way' do
        set_default_context(@user, @organization, @location)
        login_user(@user.login, 'changeme')
        assert_current_organization(@organization.name)
        assert_current_location(@location.name)

        # switches back to only org that user has
        select_organization('Any Organization')
        assert_current_organization(@organization.name)

        # switches back to only loc that user has
        select_location('Any Location')
        assert_current_location(@location.name)
      end
    end

    context 'with multiple organizations' do
      setup do
        @second_organization = FactoryGirl.create(:organization)
        @third_organization = FactoryGirl.create(:organization)
        @second_location = FactoryGirl.create(:location)
        @user.update_attributes(:organization_ids => [@organization.id, @second_organization.id], :location_ids => [@location.id, @second_location.id])
      end

      test 'any context is supported, user can switch between his orgs' do
        set_empty_default_context(users(:admin))
        login_user(users(:admin).login, 'secret')
        assert_current_organization('Any Organization')
        assert_current_location('Any Location')
        refute_available_organization(@third_organization.name)

        select_organization(@organization.name)
        assert_current_organization(@organization.name)

        visit domains_path
        assert_current_organization(@organization.name)
      end

      test 'default context is set after login but can be chagned to any context' do
        set_default_context(@user, @organization, @location)
        login_user(@user.login, 'changeme')
        assert_current_organization(@organization.name)
        assert_current_location(@location.name)

        select_organization('Any Organization')
        assert_current_organization('Any Organization')

        visit domains_path
        assert_current_organization('Any Organization')

        select_organization(@second_organization)
        assert_current_organization(@second_organization)

        visit subnets_path
        assert_current_organization(@second_organization)
      end
    end
  end

  # to integration_test_helper.rb
  def login_user(username, password)
    logout_admin
    visit "/"
    fill_in "login_login", :with => username
    fill_in "login_password", :with => password
    click_button "Log In"
    assert_current_path root_path
  end

  def set_empty_default_context(user)
    user.update_attribute :default_organization_id, nil
    user.update_attribute :default_location_id, nil
  end

  def set_default_context(user, org, loc)
    user.update_attribute :default_organization_id, org.try(:id)
    user.update_attribute :default_location_id, loc.try(:id)
  end

  def assert_available_location(location)
    within('li#location-dropdown ul') do
      assert page.has_link?(location)
    end
  end

  def refute_available_location(location)
    within('li#location-dropdown ul') do
      assert page.has_no_link?(location)
    end
  end

  def assert_available_organization(organization)
    within('li#organization-dropdown ul') do
      assert page.has_link?(organization)
    end
  end

  def refute_available_organization(organization)
    within('li#location-dropdown ul') do
      assert page.has_no_link?(organization)
    end
  end

  def assert_current_organization(organization)
    within('li#organization-dropdown > a') do
      assert page.has_content?(organization)
    end
  end

  def assert_current_location(location)
    within('li#location-dropdown > a') do
      assert page.has_content?(location)
    end
  end

  def select_organization(organization)
    within('li#organization-dropdown ul') do
      click_link organization
    end
  end

  def select_location(location)
    within('li#location-dropdown ul') do
      click_link location
    end
  end
end
