require 'integration_test_helper'

class SettingJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(settings_path, "Settings", false, true, false)
    assert page.has_link?("General", :href => "#General")
    assert page.has_link?("Puppet", :href => "#Puppet")
    assert page.has_link?("Provisioning", :href => "#Provisioning")
    assert page.has_link?("Authentication", :href => "#Auth")
  end

  test "humanized tab label for setting category" do
    class Setting::Test < Setting
      def self.humanized_category
        "My Pretty Setting Label"
      end
    end
    Foreman.settings._add(name, category: 'Setting::Test', default: false, description: 'Pretty setting', full_name: 'Pretty setting')

    assert_index_page(settings_path, "Settings", false, true, false)
    assert page.has_link?("My Pretty Setting Label", :href => "#Test")
  end
end
