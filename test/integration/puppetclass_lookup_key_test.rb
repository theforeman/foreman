require 'integration_test_helper'

class PuppetclassLookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(puppetclass_lookup_keys_path,"Smart Class Parameters",false)
  end

  test "edit page" do
    visit puppetclass_lookup_keys_path
    within(:xpath, "//table") do
      click_link "ssl"
    end
    fill_in "puppetclass_lookup_key_description", :with => "test"
    fill_in "puppetclass_lookup_key_default_value", :with => "false"
    assert_submit_button(puppetclass_lookup_keys_path)
    assert page.has_link? 'ssl'
  end
end
