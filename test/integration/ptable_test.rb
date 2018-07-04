require 'integration_test_helper'

class PtableIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @ptable = FactoryBot.create(:ptable, :ubuntu, :name => 'ubuntu default')
  end

  test "edit page" do
    visit ptables_path
    click_link "ubuntu default"
    fill_in "ptable_name", :with => "debian default"
    fill_in "ptable_template", :with => "d-i partman-auto/disk string /dev/sda\nd-i"
    assert_submit_button(ptables_path)
    assert page.has_link? 'debian default'
  end

  test "make sure that ptable names with slashes and dots work" do
    visit ptables_path
    click_link "ubuntu default"
    fill_in "ptable_name", :with => "debian.default /dev/sda"
    fill_in "ptable_template", :with => "d-i partman-auto/disk string /dev/sda\nd-i"
    assert_submit_button(ptables_path)

    assert page.has_link? 'debian.default /dev/sda'
    click_link "debian.default /dev/sda"
    assert page.has_field?("ptable_name") # not 404
  end
end
