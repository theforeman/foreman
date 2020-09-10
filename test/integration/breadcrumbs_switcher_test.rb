require 'integration_test_helper'

class BreadcrumbsSwitcherTest < IntegrationTestWithJavascript
  test "should switch between resources" do
    visit bookmarks_path
    click_link 'foo'
    click_button 'switcher'
    click_link "#{bookmarks(:three).id}-three"

    within("#edit_bookmark_#{bookmarks(:three).id}") do
      current_bookmark_name = page.find('#bookmark_name').value
      assert_equal current_bookmark_name, 'three'
    end
  end

  test "search query" do
    visit bookmarks_path
    click_link 'foo'
    click_button 'switcher'
    fill_in('breadcrumbs-search', :with => 'three')
    wait_for_ajax
    page.assert_selector('.no-border.list-group-item', count: 1)
    page.assert_selector('.no-border.list-group-item', text: 'three')
  end
end
