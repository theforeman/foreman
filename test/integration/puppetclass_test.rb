require 'integration_test_helper'

class PuppetclassIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   PuppetclassIntegrationTest.test_0001_edit page
  extend Minitest::OptionalRetry

  test "edit page" do
    visit puppetclasses_path
    click_link "vim"
    assert page.has_no_link? 'Common'
    find(:xpath, "//a[@data-original-title='Select All']").click
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
