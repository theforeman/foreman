require 'integration_test_helper'

class CommonParameterIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(global_lookup_keys_path,"Global Parameters","New Parameter")
  end

  test "create new page" do
    assert_new_button(global_lookup_keys_path,"New Parameter", new_global_lookup_key_path)
    fill_in "global_lookup_key_key", :with => "ssh_debug_key"
    fill_in "global_lookup_key_default_value", :with => "ssh-rsa AAAAB3NzaC1yc2E"
    assert_submit_button(global_lookup_keys_path)
    assert page.has_link? 'ssh_debug_key'
    assert page.has_content? 'ssh-rsa AAAAB3NzaC1yc2E'
  end

  test "edit page" do
    visit global_lookup_keys_path
    click_link "test"
    fill_in "global_lookup_key_default_value", :with => "mynewvalue"
    assert_submit_button(global_lookup_keys_path)
    assert page.has_content? 'mynewvalue'
  end

  test "does not display editor on hidden value" do
    visit global_lookup_keys_path
    click_link "test"
    check "global_lookup_key_hidden_value"
    page.assert_no_selector 'editor_source'
  end
end
