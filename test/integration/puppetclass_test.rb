require 'test_helper'

class PuppetclassTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(puppetclasses_path,"Puppet Classes","New Puppet Class")
  end

  test "create new page" do
    assert_new_button(puppetclasses_path,"New Puppet Class",new_puppetclass_path)
    fill_in "puppetclass_name", :with => "sublime"
    assert_submit_button(puppetclasses_path)
    assert page.has_link? "sublime"
  end

  test "edit page" do
    visit puppetclasses_path
    click_link "apache"
    fill_in "puppetclass_name", :with => "apache2"
    assert_submit_button(puppetclasses_path)
    assert page.has_link? 'apache2'
  end

  # PENDING
  # test "smart variables" do
  # end

  # PENDING
  # test "smart class parameters" do
  # end

end
