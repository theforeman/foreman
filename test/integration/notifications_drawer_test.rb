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
    assert page.has_selector?('#notification-badge'), "Notifications toggler was expected in the top bar, but was not found"
    assert page.has_no_selector?('.notifications'), "Notifications drawer was expected to be closed, but was found opend"

    # open notifications drawer
    page.find('#notification-badge').click
    assert page.has_selector?('.notifications'), "Notifications drawer was expected to be opend, but was found closed"

    # close notifications drawer by click on the toggler
    page.find('#notification-badge').click
    assert page.has_no_selector?('.notifications'), "Notifications drawer was expected to be closed, but was found opend"

    # open notifications drawer
    page.find('#notification-badge').click
    assert page.has_selector?('.notifications'), "Notifications drawer was expected to be opend, but was found closed"

    # close notifications drawer by click on close button
    page.find('button[aria-label="Close"]').click
    assert page.has_no_selector?('.notifications button[aria-label="Close"]'), "Notifications drawer was expected to be closed, but was found opend"

    # open notifications drawer
    page.find('#notification-badge').click
    assert page.has_selector?('.notifications'), "Notifications drawer was expected to be opend, but was found closed"

    page.find('button[aria-label="Close"]').click
  end

  def navigate_somewhere_with_turbolinks
    # check the outside click with turbolinks
    page.find('a.pf-v5-c-masthead__brand').click
    # wait for loader to dissapear
    page.has_no_selector?('div.spinner')
  end
end
