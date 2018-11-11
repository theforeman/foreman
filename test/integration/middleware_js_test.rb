require 'integration_test_helper'

class MiddlewareJSTest < IntegrationTestWithJavascript
  test 'login page appears after logout' do
    logout_admin
    visit '/environments'
    assert page.has_selector? 'input[name="login[password]"]'
  end
end
