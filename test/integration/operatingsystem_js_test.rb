require 'integration_test_helper'

class OperatingsystemJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(operatingsystems_path, "Operating Systems", "Create Operating System")
  end

  test "delete operating system" do
    os_name = 'aaa'
    os_xpath = "//tr[contains(.,'#{os_name}')]"
    os = FactoryBot.create(:operatingsystem, name: os_name)
    visit operatingsystems_path
    os_row = find("table > tbody").find(:xpath, os_xpath)
    assert_equal os.title, os_row.find("td:nth-child(1)").text.strip
    assert has_no_css?("#app-confirm-modal")

    actions = os_row.find("td:nth-child(3) > div")
    actions.find("a.dropdown-toggle").click
    actions.find("ul > li > a.delete").click

    confirm_modal = page.find("#app-confirm-modal")
    assert_equal "Confirm", confirm_modal.find(".pf-c-modal-box__title-text").text
    assert_equal "Delete #{os.title}?", confirm_modal.find(".pf-c-modal-box__body").text

    confirm_button = confirm_modal.find("footer > button:nth-child(1)")
    assert_equal "Confirm", confirm_button.text
    confirm_button.click
    assert has_no_css?("#app-confirm-modal")

    assert find("table > tbody").has_no_xpath?(os_xpath)
    refute Operatingsystem.find_by_name(os.name).present?
  end
end
