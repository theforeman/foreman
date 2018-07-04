require 'integration_test_helper'

class VariableLookupKeyJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   VariableLookupKeyJSTest.test_0001_does not turn empty boolean value to false
  test "index page" do
    assert_index_page(variable_lookup_keys_path, "Smart Variables", false)
  end
  test "does not turn empty boolean value to false" do
    visit variable_lookup_keys_path
    within(:xpath, "//table") do
      click_link "bool_test"
    end

    page.find(".add_nested_fields").click
    row = page.first(".lookup_values table tbody tr")
    row.find(".matcher_key").select('os')
    row.find(".matcher_value").set('fake')
    wait_for_ajax

    click_button('Submit')
    wait_for_ajax

    within(:xpath, "//table") do
      click_link "bool_test"
    end

    wait_for_ajax
    value_selector = page.find(".lookup_values table textarea")
    assert_equal "", value_selector.value
  end

  test "edit page" do
    visit variable_lookup_keys_path
    within(:xpath, "//table") do
      click_link "special_info"
    end
    fill_in "variable_lookup_key_key", :with => "webport"
    select2 'base', :from => 'variable_lookup_key_puppetclass_id'
    fill_in "variable_lookup_key_default_value", :with => "8080"
    assert_submit_button(variable_lookup_keys_path)
    assert page.has_link? 'webport'
  end

  test "create new page" do
    visit variable_lookup_keys_path
    first(:link, "Create Smart Variable").click
    fill_in "variable_lookup_key_key", :with => "test"
    select2 'base', :from => 'variable_lookup_key_puppetclass_id'
    fill_in "variable_lookup_key_default_value", :with => "test"
    assert_submit_button(variable_lookup_keys_path)
    assert page.has_link? 'test'
  end
end
