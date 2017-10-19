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
        @user.roles << Role.find_by_name('Manager')
      end

      test 'any context is supported, user can switch between his orgs' do
        set_empty_default_context(@user)
        login_user(@user.login, 'changeme')
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

      test 'user gets warning if he was removed from organization while he was working in it' do
        set_empty_default_context(@user)
        login_user(@user.login, 'changeme')
        select_organization(@organization)
        visit domains_path
        assert_current_organization(@organization.name)

        @user.organization_ids = [@second_organization.id, @third_organization.id]

        visit domains_path
        assert_current_organization('Any Organization')
        assert_warning 'Organization you had selected as your context has been deleted'

        @user.organization_ids = [@second_organization.id]
        visit domains_path
        assert_current_organization(@second_organization.name)
        assert_warning 'Organization you had selected as your context has been deleted'
      end

      test 'user gets warning if he has default organization set and he/she does not have access to it anymore' do
        set_default_context(@user, @organization, @location)
        login_user(@user.login, 'changeme')
        visit domains_path
        assert_current_organization(@organization.name)

        @user.organization_ids = [@second_organization.id, @third_organization.id]

        visit domains_path
        assert_current_organization('Any Organization')
        assert_warning 'Organization you had selected as your context has been deleted'

        @user.organization_ids = [@second_organization.id]
        visit domains_path
        assert_current_organization(@second_organization.name)
        assert_warning 'Organization you had selected as your context has been deleted'
      end

      test 'user organization resets to any org if he/she has default organization but does not have access to it while she/he has access to 2 or more orgs' do
        set_default_context(@user, @organization, @location)
        @user.organization_ids = [@second_organization.id, @third_organization.id]

        login_user(@user.login, 'changeme')
        assert_current_organization('Any Organization')
      end

      test 'user organization resets to the his/her only org if he/she has default organization but does not have access to it' do
        set_default_context(@user, @organization, @location)
        @user.organization_ids = [@second_organization.id]

        login_user(@user.login, 'changeme')
        assert_current_organization(@second_organization.name)
      end
    end
  end
end
