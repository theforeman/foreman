require 'integration_test_helper'

class PuppetclassLookupKeyJSTest < IntegrationTestWithJavascript
  test 'can hide value when overriden' do
    visit puppetclass_lookup_keys_path
    within(:xpath, "//table") do
      click_link "port"
    end
    page.find("#puppetclass_lookup_key_override").click
    assert page.find("#puppetclass_lookup_key_hidden_value:enabled")
  end

  test "uncheck override" do
    visit puppetclass_lookup_keys_path
    within(:xpath, "//table") do
      click_link "ssl"
    end

    page.find("#puppetclass_lookup_key_hidden_value").click

    assert_submit_button(puppetclass_lookup_keys_path)
    wait_for_ajax

    within(:xpath, "//table") do
      click_link "ssl"
    end

    page.find("#puppetclass_lookup_key_override").click

    assert_submit_button(puppetclass_lookup_keys_path)
    wait_for_ajax

    within(:xpath, "//table") do
      click_link "ssl"
    end

    assert page.find("#puppetclass_lookup_key_hidden_value").checked?
  end
end
