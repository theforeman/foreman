require 'integration_test_helper'

class VariableLookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(variable_lookup_keys_path,"Smart variables",false)
  end

  test "edit page" do
    visit variable_lookup_keys_path
    within(:xpath, "//table") do
      click_link "special_info"
    end
    fill_in "variable_lookup_key_key", :with => "webport"
    select "base", :from => "variable_lookup_key_puppetclass_id"
    fill_in "variable_lookup_key_default_value", :with => "8080"
    assert_submit_button(variable_lookup_keys_path)
    assert page.has_link? 'webport'
  end

  test "create new page" do
    assert_new_button(variable_lookup_keys_path,"Create Smart Variable", new_variable_lookup_key_path)
    fill_in "variable_lookup_key_key", :with => "test"
    select "base", :from => "variable_lookup_key_puppetclass_id"
    fill_in "variable_lookup_key_default_value", :with => "test"
    assert_submit_button(variable_lookup_keys_path)
    assert page.has_link? 'test'
  end
end
