require 'test_helper'

class DisableTurbolinksTest < ActionDispatch::IntegrationTest
  test "should disable turbolinks" do
    proxy = FactoryGirl.create(:smart_proxy)
    DisableTurbolinks.register ["smart_proxies/show"]
    visit smart_proxies_path
    assert page.has_link? proxy.name
    assert page.find('a[data-no-turbolink=""]', :text => proxy.name)
  end
end
