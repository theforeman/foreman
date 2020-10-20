require 'integration_test_helper'

class LoginPageTest < IntegrationTestWithJavascript
  test 'login page appears after logout' do
    logout_admin
    visit '/domains'
    assert page.has_selector? 'input[name="login[password]"]'
  end
end
