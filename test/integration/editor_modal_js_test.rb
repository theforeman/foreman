require 'integration_test_helper'

class EditorModalJsTest < IntegrationTestWithJavascript
  test "check empty modal" do
    visit new_report_template_path

    find('#fullscreen-btn').click
    assert has_editor_display?('#editor-modal', '')

    find('button[data-ouia-component-id="editor-modal-component-ModalBoxCloseButton"]').click

    assert_no_selector '#editor-modal'
  end

  test "check editing view with data" do
    template = FactoryBot.create(:report_template)
    visit report_templates_path
    click_link(template.name)

    find('#fullscreen-btn').click
    assert_selector('#editor-modal-h4', text: template.name)

    assert has_editor_display?('#editor-container', template.template)
  end
end
