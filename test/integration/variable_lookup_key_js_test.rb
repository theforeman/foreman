require 'integration_test_helper'

class VariableLookupKeyJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   VariableLookupKeyJSTest.test_0001_does not turn empty boolean value to false
  extend Minitest::OptionalRetry

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
    value_selector = page.first(".lookup_values table tbody tr textarea")
    assert_equal "", value_selector.value
  end
end
