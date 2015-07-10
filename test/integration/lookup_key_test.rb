require 'test_helper'

class LookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(lookup_keys_path,"Smart variables",false)
  end

  test "edit page" do
    visit lookup_keys_path
    within(:xpath, "//table") do
      click_link "special_info"
    end
    fill_in "lookup_key_key", :with => "webport"
    select "base", :from => "lookup_key_puppetclass_id"
    fill_in "lookup_key_default_value", :with => "8080"
    assert_submit_button(lookup_keys_path)
    assert page.has_link? 'webport'
  end
end
