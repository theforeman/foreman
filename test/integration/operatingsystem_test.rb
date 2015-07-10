require 'test_helper'

class OperatingsystemIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(operatingsystems_path,"Operating systems","New Operating system")
  end

  test "create new page" do
    assert_new_button(operatingsystems_path,"New Operating system",new_operatingsystem_path)
    fill_in "operatingsystem_name", :with => "Archy"
    fill_in "operatingsystem_major", :with => "9"
    fill_in "operatingsystem_minor", :with => "2"
    select "Arch Linux", :from => "operatingsystem_family"
    check "x86_64"
    assert_submit_button(operatingsystems_path)
    assert page.has_link? "Archy 9.2"
  end

  test "edit page" do
    visit operatingsystems_path
    click_link "centos 5.3"
    fill_in "operatingsystem_major", :with => "6"
    assert_submit_button(operatingsystems_path)
    assert page.has_link? 'centos 6.3'
  end

  # PENDING
  # test "add parameters" do
  # end

  # PENDING
  # test "add templates" do
  # end
end
