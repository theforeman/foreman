require 'integration_test_helper'

class NotificationsDrawerIntegrationTest < IntegrationTestWithJavascript
  test "notifications drawer test with turbolinks" do
    visit root_path

    notifications_open_and_close_flow

    navigate_somewhere_with_turbolinks

    notifications_open_and_close_flow
  end

  private

  def notifications_open_and_close_flow
    within(".notifications_container") do
      assert page.has_selector?('.fa.fa-bell-o'), "Notifications toggler was expected in the top bar, but was not found"
      assert page.has_no_selector?('.drawer-pf'), "Notifications drawer was expected to be closed, but was found opend"

      # open notifications drawer
      page.find('.fa.fa-bell-o').click
      assert page.has_selector?('.drawer-pf'), "Notifications drawer was expected to be opend, but was found closed"

      # close notifications drawer by click on the toggler
      page.find('.fa.fa-bell-o').click
      assert page.has_no_selector?('.drawer-pf'), "Notifications drawer was expected to be closed, but was found opend"

      # open notifications drawer
      page.find('.fa.fa-bell-o').click
      assert page.has_selector?('.drawer-pf'), "Notifications drawer was expected to be opend, but was found closed"

      # close notifications drawer by click on close button
      page.find('.drawer-pf-notifications').click # to remove the tooltip from the icon
      page.find('.drawer-pf-close').click
      assert page.has_no_selector?('.drawer-pf'), "Notifications drawer was expected to be closed, but was found opend"

      # open notifications drawer
      page.find('.fa.fa-bell-o').click
      assert page.has_selector?('.drawer-pf'), "Notifications drawer was expected to be opend, but was found closed"
    end

    # close notifications drawer by click outside
    page.find('body').click
    assert page.has_no_selector?('.notifications_container .drawer-pf'), "Notifications drawer was expected to be closed, but was found opend"
  end

  def navigate_somewhere_with_turbolinks
    # check the outside click with turbolinks
    page.find('a.navbar-brand').click
    # wait for loader to dissapear
    page.has_no_selector?('div.spinner')
  end
end
