require 'test_helper'

class PuppetclassTest < ActionDispatch::IntegrationTest

  test "edit page" do
    visit puppetclasses_path
    click_link "vim"
    fill_in "puppetclass_name", :with => "vim_renamed"
    assert_submit_button(puppetclasses_path)
    assert page.has_link? 'vim_renamed'
  end

  # PENDING
  # test "smart variables" do
  # end

  # PENDING
  # test "smart class parameters" do
  # end

end
