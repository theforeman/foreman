require 'integration_test_helper'

class SettingJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(settings_path, "Settings", false, true, false)
    assert page.has_link?("General", :href => "#general_settings_tab")
    assert page.has_link?("Provisioning", :href => "#provisioning_settings_tab")
    assert page.has_link?("Facts", :href => "#facts_settings_tab")
    assert page.has_link?("Config Management", :href => "#cfgmgmt_settings_tab")
    assert page.has_link?("Authentication", :href => "#auth_settings_tab")
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
    assert page.has_link?("My Pretty Setting Label", :href => "#category_label_test_settings_tab")
  end

  test "general headers values" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    assert_text 'Name'
    assert_text 'Value'
    assert_text 'Description'
  end

  test "edit single arrays values" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    click_button 'http_proxy_except_list'

    input = find('textarea#setting-textarea-http_proxy_except_list')
    assert_empty input.value

    input.fill_in with: 'testArr'
    find(:ouia_component_id, 'submit-edit-btn').click
    assert_text 'updated setting'

    assert_text '[testArr]'
  end

  test "edit empty array values" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    click_button 'http_proxy_except_list'

    input = find('textarea#setting-textarea-http_proxy_except_list')
    assert_empty input.value

    input.fill_in with: ''
    find(:ouia_component_id, 'submit-edit-btn').click
    assert_text 'updated setting'

    assert_text '[]'
  end

  test "edit multi array values" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    click_button 'http_proxy_except_list'

    input = find('textarea#setting-textarea-http_proxy_except_list')
    assert_empty input.value

    input.fill_in with: 'testArr,testArr2'
    find(:ouia_component_id, 'submit-edit-btn').click
    assert_text 'updated setting'

    assert_text '[testArr, testArr2]'
  end

  test "string input type" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    click_button 'entries_per_page'

    input = find('input#setting-input-entries_per_page')
    assert_equal input.value, '20'

    input.fill_in with: '25'
    find(:ouia_component_id, 'submit-edit-btn').click

    assert_text '25'
  end

  test "select input type" do
    visit settings_path
    assert_no_selector('.pf-v5-c-skeleton', wait: 25)

    click_button 'default_timezone'

    select "(GMT +01:00) Berlin", from: 'setting-select-default_timezone'
    find(:ouia_component_id, 'submit-edit-btn').click

    assert_text '(GMT +01:00) Berlin'
  end
end
