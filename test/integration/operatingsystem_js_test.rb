require 'integration_test_helper'

class OperatingsystemJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(operatingsystems_path, "Operating Systems", "Create Operating System")
  end

  test "delete operating system" do
    visit operatingsystems_path
    first_row = find("table > tbody > tr:nth-child(1)")
    assert first_row.find("td:nth-child(1)").text, "centos 5.3"
    assert has_no_css?("#app-confirm-modal")

    actions = first_row.find("td:nth-child(3) > div")
    actions.find("a.dropdown-toggle").click
    actions.find("ul > li > a.delete").click

    confirm_modal = page.find("#app-confirm-modal")
    assert confirm_modal.find(".pf-c-modal-box__title-text").text, "Confirm"
    assert confirm_modal.find(".pf-c-modal-box__body").text, "Delete centos 5.3?"

    confirm_button = confirm_modal.find("footer > button:nth-child(1)")
    assert confirm_button.text, "Confirm"
    confirm_button.click
    assert has_no_css?("#app-confirm-modal")
  end
end
