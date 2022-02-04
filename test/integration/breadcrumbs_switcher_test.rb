require 'integration_test_helper'

class BreadcrumbsSwitcherTest < IntegrationTestWithJavascript
  test "should switch between resources" do
    visit bookmarks_path
    click_link 'foo'
    click_button 'open breadcrumb switcher'
    click_link "three"

    within("#edit_bookmark_#{bookmarks(:three).id}") do
      current_bookmark_name = page.find('#bookmark_name').value
      assert_equal current_bookmark_name, 'three'
    end
  end

  test "search query" do
    visit bookmarks_path
    click_link 'foo'
    click_button 'open breadcrumb switcher'
    fill_in('Filter breadcrumb items', :with => 'three')
    wait_for_ajax
    page.assert_selector('.pf-c-menu__item-main', count: 1)
    page.assert_selector('.pf-c-menu__item-main', text: 'three')
  end
end
