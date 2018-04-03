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
end
