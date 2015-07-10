require 'test_helper'

class ArchitectureIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(architectures_path,"Architectures","New Architecture")
  end

  test "create new page" do
    assert_new_button(architectures_path,"New Architecture",new_architecture_path)
    fill_in "architecture_name", :with => "i386"
    assert_submit_button(architectures_path)
    assert page.has_link? 'i386'
  end

  test "edit page" do
    visit architectures_path
    click_link "x86_64"
    fill_in "architecture_name", :with => "z128"
    assert_submit_button(architectures_path)
    assert page.has_link? 'z128'
  end
end
