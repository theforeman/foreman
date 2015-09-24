require 'test_helper'

class SettingIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(settings_path,"Settings",false,true,false)
    assert page.has_link?("General", :href => "#General")
    assert page.has_link?("Configuration", :href => "#Configuration")
    assert page.has_link?("Provisioning", :href => "#Provisioning")
    assert page.has_link?("Auth", :href => "#Auth")
  end
end
