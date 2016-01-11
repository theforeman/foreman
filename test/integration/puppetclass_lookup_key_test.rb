require 'test_helper'

class PuppetclassLookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(puppetclass_lookup_keys_path,"Smart class parameters",false)
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

  describe 'js tests' do
    setup do
      @driver = Capybara.current_driver
      Capybara.current_driver = Capybara.javascript_driver
      login_admin
    end

    teardown do
      Capybara.current_driver = @driver
    end

    test 'can hide value when overriden' do
      visit puppetclass_lookup_keys_path
      within(:xpath, "//table") do
        click_link "port"
      end
      page.find("#puppetclass_lookup_key_override").click
      assert page.find("#puppetclass_lookup_key_hidden_value:enabled")
    end
  end
end
