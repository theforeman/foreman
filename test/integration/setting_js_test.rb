require 'integration_test_helper'

class SettingJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(settings_path, "Settings", false, true, false)
    assert page.has_link?("General", :href => "#general")
    assert page.has_link?("Puppet", :href => "#Puppet")
    assert page.has_link?("Provisioning", :href => "#Provisioning")
    assert page.has_link?("Authentication", :href => "#auth")
  end

  test "humanized tab label for setting category" do
    setting_memo = Foreman::SettingManager.settings.dup
    category_memo = Foreman::SettingManager.categories.dup
    Foreman::SettingManager.stubs(settings: setting_memo, categories: category_memo)
    Foreman::SettingManager.define(:test_context) do
      category(:category_label_test, 'My Pretty Setting Label') do
        setting(:foo_category_test,
          type: :boolean,
          default: false,
          description: 'Pretty setting',
          full_name: 'Pretty setting')
      end
    end

    Foreman.settings.load

    assert_index_page(settings_path, "Settings", false, true, false)
    assert page.has_link?("My Pretty Setting Label", :href => "#category_label_test")
  end
end
