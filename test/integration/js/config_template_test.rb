require 'test_helper'

class ConfigTemplateTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "create new config template" do
    assert_new_button(config_templates_path,"New Template",new_config_template_path)
    fill_in "config_template_name", :with => "linux6_3_pxelinux"
    select "PXELinux", :from => "config_template_template_kind_id"
    fill_in "config_template_template", :with => "default linux~label linux~kernel"
    assert_submit_button(config_templates_path)
    assert page.has_link? 'linux6_3_pxelinux'
  end

  test "edit config template" do
    visit config_templates_path
    click_link "centos5_3_pxelinux"
    fill_in "config_template_name", :with => "linux_gpxe"
    select "gPXE", :from => "config_template_template_kind_id"
    assert_submit_button(config_templates_path)
    assert page.has_link? 'linux_gpxe'
    assert page.has_content? 'Successfully updated'
  end

  test "sucessfully delete row" do
    assert_delete_row(config_templates_path, "PXE Localboot Default")
  end

  test "cannot delete row if used" do
    assert_cannot_delete_row(config_templates_path, "centos5_3_pxelinux")
  end

  # PENDING
  # test "Build PXE Default" do
  # end

end
