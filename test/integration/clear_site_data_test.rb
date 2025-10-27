require 'integration_test_helper'

class ClearSiteDataTest < IntegrationTestWithJavascript
  test 'logout clears browser storage' do
    visit '/domains'
    assert page.has_content?('Domains'), 'Should be logged in and on domains page'

    # Set test data in browser storage
    page.execute_script(<<~JAVASCRIPT)
      localStorage.setItem('test-local-storage', 'should-be-cleared');
      sessionStorage.setItem('test-session-storage', 'should-be-cleared');
      document.cookie = 'test-logout-cookie=should-be-cleared; path=/';
    JAVASCRIPT

    # Verify test data was set
    assert_equal 'should-be-cleared', page.evaluate_script("localStorage.getItem('test-local-storage')")
    assert_equal 'should-be-cleared', page.evaluate_script("sessionStorage.getItem('test-session-storage')")

    # Perform logout
    logout_admin

    # Should be redirected to login page
    assert page.has_selector?('input[name="login[password]"]'), 'Should be redirected to login page after logout'

    # Check if storage was cleared (this tests the actual browser behavior)
    local_storage_after = page.evaluate_script("localStorage.getItem('test-local-storage')")
    session_storage_after = page.evaluate_script("sessionStorage.getItem('test-session-storage')")
    cookies_after = page.evaluate_script("document.cookie")

    assert_nil local_storage_after, 'localStorage should be cleared after logout'
    assert_nil session_storage_after, 'sessionStorage should be cleared after logout'
    refute_includes cookies_after, 'test-logout-cookie=should-be-cleared', 'Test cookie should be cleared after logout'
  end

  test 'normal page navigation does not clear storage' do
    visit '/domains'
    assert page.has_content?('Domains'), 'Should be on Domains page'

    # Set test data
    page.execute_script("localStorage.setItem('test-persist', 'should-remain')")

    # Navigate to different page
    visit '/users'
    assert page.has_content?('Users'), 'Should be on users page'

    # Data should still be there
    assert_equal 'should-remain', page.evaluate_script("localStorage.getItem('test-persist')")
  end
end
