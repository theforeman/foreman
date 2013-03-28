require 'test_helper'

class PtableTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(ptables_path,"Partition Tables","New Partition Table Layout")
  end

  test "create new page" do
    assert_new_button(ptables_path,"New Partition Table Layout",new_ptable_path)
    fill_in "ptable_name", :with => "ubuntu 123 layout"
    fill_in "ptable_layout", :with => "d-i partman-auto/disk string"
    select "Debian", :from => "ptable_os_family"
    assert_submit_button(ptables_path)
    assert page.has_link? "ubuntu 123 layout"
  end

  test "edit page" do
    visit ptables_path
    click_link "ubuntu default"
    fill_in "ptable_name", :with => "debian default"
    fill_in "ptable_layout", :with => "d-i partman-auto/disk string /dev/sda\nd-i"
    assert_submit_button(ptables_path)
    assert page.has_link? 'debian default'
  end

end
