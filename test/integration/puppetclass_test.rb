require 'test_helper'

class PuppetclassIntegrationTest < ActionDispatch::IntegrationTest
  test "edit page" do
    visit puppetclasses_path
    click_link "vim"
    refute page.has_link? 'Common'
    click_link "Select All"
    assert_submit_button(puppetclasses_path)
    assert page.has_link? 'vim'
    assert page.has_link? 'Common'
  end

  # PENDING
  # test "smart variables" do
  # end

  # PENDING
  # test "smart class parameters" do
  # end
end
