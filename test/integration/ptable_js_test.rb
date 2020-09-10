require 'integration_test_helper'

class PtableJSTest < IntegrationTestWithJavascript
  setup do
    @ptable = FactoryBot.create(:ptable, :ubuntu, :name => 'ubuntu default')
  end

  test "index page" do
    assert_index_page(ptables_path, "Partition Tables", "Create Partition Table")
  end

  test "edit page" do
    visit ptables_path
    click_link "ubuntu default"
    fill_in "ptable_name", :with => "debian default"

    editor_text = "d-i partman-auto/disk string /dev/sda\nd-i"
    fill_in_editor_field('#editor-container', editor_text)
    assert has_editor_display?('#editor-container', editor_text)

    assert_submit_button(ptables_path)
    assert page.has_link? 'debian default'
  end

  test "make sure that ptable names with slashes and dots work" do
    visit ptables_path
    click_link "ubuntu default"
    fill_in "ptable_name", :with => "debian.default /dev/sda"

    editor_text = "d-i partman-auto/disk string /dev/sda\nd-i"
    fill_in_editor_field('#editor-container', editor_text)

    assert_submit_button(ptables_path)

    assert page.has_link? 'debian.default /dev/sda'
    click_link "debian.default /dev/sda"
    assert page.has_field?("ptable_name") # not 404
    assert has_editor_display?('#editor-container', editor_text)
  end
end
