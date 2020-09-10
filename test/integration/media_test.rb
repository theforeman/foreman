require 'integration_test_helper'

class MediaIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(media_path, "Create Medium", new_medium_path)
    fill_in "medium_name", :with => "Fedora Mirror 123"
    fill_in "medium_path", :with => "http://download.eng.tlv.redhat.com/pub/fedora123/linux/releases/$major/Fedora/$arch/os"
    select "Red Hat", :from => "medium_os_family"
    assert_submit_button(media_path)
    assert page.has_link? 'Fedora Mirror 123'
  end

  test "edit page" do
    visit media_path
    click_link "Ubuntu Mirror"
    fill_in "medium_name", :with => "Ubuntu Mirror 123"
    select "Debian", :from => "medium_os_family"
    assert_submit_button(media_path)
    assert page.has_link? 'Ubuntu Mirror 123'
  end
end
